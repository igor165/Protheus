// #########################################################################################
// Projeto: Trato
// Fonte  : vapcpa07
// ---------+------------------------------+------------------------------------------------
// Data     | Autor: JRScatolon            | Descri��o
// ---------+------------------------------+------------------------------------------------
// 20190227 | jrscatolon@jrscatolon.com.br | Lote x Plano nutricional 
//          |                              |  
//          |                              |  
// ---------+------------------------------+------------------------------------------------

// Parametro:  VA_PCPA07U
// Tipo:       L
// Descri��o:  Identifica se os registros da tabela Z0O ser�o excluidos (soft deletet) (.t.) ou eliminados do banco (.f.).

#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
#include "parmtype.ch"
#include "fwmvcdef.ch"
#INCLUDE "TOTVS.CH"

static cPath    := "C:\totvs_relatorios\"
static lDebug   := ExistDir(cPath) .and. GetMV("VA_DBGTRTO",,.t.)

static aCposSB8 :={ "B8_X_CURRA",;
                    "B8_LOTECTL",;
                    "Z0M_DESCRI",;
                    "Z0O_DATAIN",;
                    "Z0O_DIAIN",;
                    "B8_SALDO",;
                    "PESO_INIC",;
                    "PESO_ATUAL",;
                    "PESO_FINAL",;
                    "B8_XDATACO",;
                    "B8_DIASCO",;
                    "Z0O_GMD",;
                    "Z0O_DCESP",;
                    "B8_XPESOCO"}
// Z0O_PESO -> Virtual ->  Carregar o campo Z0M_PESO
static aCposZ0O :={ "Z0O_CODPLA",;
                    "Z0O_DESPLA",;
                    "Z0O_DATAIN",;
                    "Z0O_DIAIN",;
                    "Z0O_DATATR",;
                    "Z0O_GMD" ,;
                    "Z0O_DCESP ",;
                    "Z0O_RENESP",;
                    "Z0O_CMSPRE",;
                    "Z0O_PESO",;
                    "Z0O_SEXO",;   // novos campos
                    "Z0O_TAMCAR",;
                    "Z0O_GORDUR",;
                    "Z0O_FS",;
                    "Z0O_PESOPR",;
                    "Z0O_MCALPR",;
                    "Z0O_RACA"  ,;
                    "Z0O_MCAPV" ,;
                    "Z0O_DTABAT",;
                    "Z0O_DIARIA" }
/*/{Protheus.doc} vapcpa07
//Carrega a rotina de Lote x Plano nutricional

@author guima
@since 20/03/2019
@version 1.0
@return nil

@type function
/*/
user function vapcpa07()
local i, nLen
// local cSql := ""

local aFields     := {}
local aBrowse     := {}
local aFieFilter  := {}
local aIndex      := {}
local aSeek       := {}

private oBrowse   := nil
private aRotina   := MenuDef()
private cAlias    := "SB8"
private cDescri   := "Lote x Plano nutricional"
private cAliasTMP := CriaTrab(,.f.)
private cPerg     := "VAPCPA07"
private oTmpSB8   := nil
private bF12      := SetKey(VK_F12, {|| u_povoaBrw() })

//------------------------------------------------
//Carrega as tabelas que ser�o usadas pela rotina 
//------------------------------------------------
DbSelectArea("Z05")
DbSetOrder(1) // Z05_FILIAL+Z05_DATA+Z05_CURRAL+Z05_VERSAO

DbSelectArea("Z0M")
DbSetOrder(1) // Z0M_FILIAL+Z0M_CODIGO+Z0M_VERSAO+Z0M_DIA+Z0M_TRATO

DbSelectArea("SB8")
DbSetOrder(1) //B8_FILIAL+B8_PRODUTO+B8_LOCAL+DTOS(B8_DTVALID)+B8_LOTECTL+B8_NUMLOTE

DbSelectArea("Z0O")
DbSetOrder(1) // Z0O_FILIAL+Z0O_LOTE+Z0O_CODPLA

//------------------------------------------------
//Cria a pergunta VAPCPA07 e carrega os parametros 
//da rotina. 
//------------------------------------------------
U_AtuSX107(cPerg)

//-----------------------------------------------
//Monta os campos da tabela tempor�ria e o browse
//-----------------------------------------------
SX3->(DbSetOrder(2)) // X3_CAMPO
nLen := Len(aCposSB8)
for i := 1 to nLen
    if aCposSB8[i] $ "PESO_INIC"
        AAdd(aFields,{"PESO_INIC", "N", 8, 2})
        AAdd(aBrowse, {"Peso Inicial", "PESO_INIC", "N", 8, 2, "@E 99,999.99"})
        AAdd(aFieFilter, {"PESO_INIC", "Peso Inicial", "N", 8, 2, "@E 99,999.99"})
    elseif aCposSB8[i] $ "PESO_ATUAL"
        AAdd(aFields,{"PESO_ATUAL", "N", 8, 2})
        AAdd(aBrowse, {"Peso Atual Proj", "PESO_ATUAL", "N", 8, 2, "@E 99,999.99"})
        AAdd(aFieFilter, {"PESO_ATUAL", "Peso Atual Proj", "N", 8, 2, "@E 99,999.99"})
    elseif aCposSB8[i] $ "PESO_FINAL"
        AAdd(aFields,{"PESO_FINAL", "N", 8, 2})
        AAdd(aBrowse, {"Peso Final Proj", "PESO_FINAL", "N", 8, 2, "@E 99,999.99"})
        AAdd(aFieFilter, {"PESO_FINAL", "Peso Final Proj", "N", 8, 2, "@E 99,999.99"})
    // elseif aCposSB8[i] $ "B8_SALDO"
    //     AAdd(aFields,{"B8_SALDO", "C", 3, 0})
    //     AAdd(aBrowse, {"Saldo Lote  ", "B8_SALDO", "C", 3, 0, "@E 999"})
    //     AAdd(aFieFilter, {"B8_SALDO", "Saldo Lote  ", "C", 3, 0, "@E 999"})
    elseif aCposSB8[i] $ "B8_DIASCO"
        AAdd(aFields,{"B8_DIASCO", "C", 3, 0})
        AAdd(aBrowse, {"Dias Cocho  ", "B8_DIASCO", "C", 3, 0, "@E 999"})
        AAdd(aFieFilter, {"B8_DIASCO", "Dias Cocho  ", "C", 3, 0, "@E 999"})
    else
        SX3->(DbSeek(aCposSB8[i]))
        AAdd(aFields,{SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL})
        AAdd(aBrowse, {X3Titulo(), SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE})
        AAdd(aFieFilter, {SX3->X3_CAMPO, X3Titulo(), SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE})
    endif
next

//-------------------
//Cria��o do objeto
//-------------------
oTmpSB8 := FWTemporaryTable():New(cAliasTMP)
oTmpSB8:SetFields(aFields)

//-------------------
//Ajuste dos �ndices
//-------------------
// "B8_X_CURRA", "B8_LOTECTL", "Z0M_DESCRI", "Z0O_DATAIN", "Z0O_DIAIN", "B8_SALDO", "PESO_INIC", "PESO_ATUAL", "PESO_FINAL", "B8_XDATACO", "B8_DIASCO", "Z0O_GMD", "Z0O_DCESP"

oTmpSB8:AddIndex(cAliasTMP + "1", {"B8_X_CURRA"})
oTmpSB8:AddIndex(cAliasTMP + "2", {"B8_LOTECTL"})
oTmpSB8:AddIndex(cAliasTMP + "3", {"Z0O_DATAIN"})
oTmpSB8:AddIndex(cAliasTMP + "4", {"B8_DIASCO"})
oTmpSB8:AddIndex(cAliasTMP + "5", {"B8_SALDO"})
oTmpSB8:AddIndex(cAliasTMP + "6", {"Z0M_DESCRI"})

AAdd(aIndex, "B8_X_CURRA")
AAdd(aIndex, "B8_LOTECTL")
AAdd(aIndex, "Z0O_DATAIN")
AAdd(aIndex, "B8_DIASCO")
AAdd(aIndex, "B8_SALDO")
AAdd(aIndex, "Z0M_DESCRI")

AAdd(aSeek,{"Curral", {{"", TamSX3("B8_X_CURRA")[3],  TamSX3("B8_X_CURRA")[1],  TamSX3("B8_X_CURRA")[2],  "B8_X_CURRA",  "@!"}}, 1, .t. })
AAdd(aSeek,{"Lote",{{"", TamSX3("B8_LOTECTL")[3], TamSX3("B8_LOTECTL")[1], TamSX3("B8_LOTECTL")[2], "B8_LOTECTL", "@!"}}, 2, .t. })
AAdd(aSeek,{"Data Inicio PL",{{"", TamSX3("Z0O_DATAIN")[3], TamSX3("Z0O_DATAIN")[1], TamSX3("Z0O_DATAIN")[2], "Z0O_DATAIN", "@!"}}, 3, .t. })
AAdd(aSeek,{"Dias Cocho",{{"", "C", 3, 0, "B8_DIASCO", "@E 999"}}, 4, .t. })

// AAdd(aSeek,{"Saldo Lote",{{"", "C", 3, 0, "B8_SALDO", "@E 999"}}, 5, .t. })
AAdd(aSeek,{"Saldo Lote",{{"", TamSX3("B8_SALDO")[3],  TamSX3("B8_SALDO")[1],  TamSX3("B8_SALDO")[2], "B8_SALDO", X3Picture("B8_SALDO")}}, 5, .t. })

AAdd(aSeek,{"Descri��o PL",{{"", TamSX3("Z0M_DESCRI")[3], TamSX3("Z0M_DESCRI")[1], TamSX3("Z0M_DESCRI")[2], "Z0M_DESCRI", "@!"}}, 6, .t. })

//------------------
//Cria��o da tabela
//------------------
oTmpSB8:Create()

u_povoaBrw(.f.)

DbSelectArea("SX2")
DbSetOrder(1)
DbSeek(cAlias)

    //Cria um browse para a SX5, filtrando somente a tabela 00 (cabe�alho das tabelas
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias(cAliasTMP)
    oBrowse:SetQueryIndex(aIndex)
    oBrowse:SetTemporary(.t.)
    oBrowse:SetFields(aBrowse)

    oBrowse:SetUseFilter(.f.)
    oBrowse:SetUseCaseFilter(.f.)
    oBrowse:DisableDetails()    

    oBrowse:SetDescription(SX2->X2_NOME)
    oBrowse:SetSeek(.t.,aSeek)
    oBrowse:Activate()

(cAliasTMP)->(DbCloseArea())

if oTmpSB8 <> nil
    oTmpSB8:Delete()
    oTmpSB8 := nil
endif

SetKey(VK_F12, bF12)
return nil

user function povoaBrw(lPergunte) 
local cSql := ""
local nPos := 0
default lPergunte := .t.

if Type("oBrowse") <> 'U'
    nPos := oBrowse:nAt 
endif

//-----------------------------------------------
//Monta a query que carrega os dados dos lotes de 
//acordo com os parametros passados
//-----------------------------------------------
Pergunte(cPerg, lPergunte)
if TCSqlExec("delete from " + oTmpSB8:GetRealName()) >= 0
    cSql :=   " insert into " + oTmpSB8:GetRealName() + CRLF +;
                         "( B8_X_CURRA" + CRLF +;
                         ", B8_LOTECTL" + CRLF +;
                         ", Z0M_DESCRI" + CRLF +;
                         ", Z0O_DATAIN" + CRLF +;
                         ", Z0O_DIAIN " + CRLF +;
                         ", B8_SALDO" + CRLF +;
                         ", PESO_INIC" + CRLF +;
                         ", PESO_ATUAL" + CRLF +;
                         ", PESO_FINAL" + CRLF +;
                         ", B8_XDATACO" + CRLF +;
                         ", B8_DIASCO " + CRLF +;
                         ", Z0O_GMD" + CRLF +;
                         ", Z0O_DCESP" + CRLF +;
                         ", B8_XPESOCO" + CRLF +;
                         ")" + CRLF +;
                   " select SB8.B8_X_CURRA" + CRLF +;
                        " , SB8.B8_LOTECTL" + CRLF +;
                         ", isnull(Z0M_DESCRI,'') Z0M_DESCRI" + CRLF +;
                         ", isnull(Z0O_DATAIN,'') Z0O_DATAIN" + CRLF +;
                         ", isnull(Z0O_DIAIN ,'') Z0O_DIAIN " + CRLF +; // "-- , right('000'+rtrim(cast(sum(SB8.B8_SALDO) as varchar(3))), 3) B8_SALDO" + CRLF +;
                         ", sum(SB8.B8_SALDO) B8_SALDO" + CRLF 
                    if mv_par01 == 1 // Lotes ativos
                 cSql += ", sum(SB8.B8_XPESOCO*SB8.B8_SALDO)/sum(SB8.B8_SALDO) PESO_INIC" + CRLF +;
                         ", isnull(sum(SB8.B8_XPESOCO*SB8.B8_SALDO)/sum(SB8.B8_SALDO)+((CAST(convert(datetime, getdate(), 103) - convert(datetime, min(SB8.B8_XDATACO), 103) AS numeric))*Z0O_GMD),0) PESO_ATUAL" + CRLF +;
                         ", isnull(sum(SB8.B8_XPESOCO*SB8.B8_SALDO)/sum(SB8.B8_SALDO)+(Z0O_DCESP*Z0O_GMD),0) PESO_FINAL" + CRLF 
                    elseif mv_par01 == 2 // Lote Finalizados
                 cSql += ", sum(SB8.B8_XPESOCO*SB8.B8_QTDORI)/sum(SB8.B8_QTDORI) PESO_INIC" + CRLF +;
                         ", isnull(sum(SB8.B8_XPESOCO*SB8.B8_QTDORI)/sum(SB8.B8_QTDORI)+((CAST(convert(datetime, getdate(), 103) - convert(datetime, min(SB8.B8_XDATACO), 103) AS numeric))*Z0O_GMD),0) PESO_ATUAL" + CRLF +;
                         ", isnull(sum(SB8.B8_XPESOCO*SB8.B8_QTDORI)/sum(SB8.B8_QTDORI)+(Z0O_DCESP*Z0O_GMD),0) PESO_FINAL" + CRLF 
                    elseif mv_par01 == 3 // Lote Finalizados
                 cSql += ", sum(SB8.B8_XPESOCO*SB8.B8_QTDORI)/sum((CASE WHEN SB8.B8_SALDO > 0 THEN B8_SALDO ELSE SB8.B8_QTDORI END)) PESO_INIC " + CRLF +;
                         ", isnull(sum(SB8.B8_XPESOCO*(CASE WHEN SB8.B8_SALDO > 0 THEN B8_SALDO ELSE SB8.B8_QTDORI END))/sum((CASE WHEN SB8.B8_SALDO > 0 THEN B8_SALDO ELSE SB8.B8_QTDORI END))+((CAST(convert(datetime, getdate(), 103) - convert(datetime, min(SB8.B8_XDATACO), 103) AS numeric))*Z0O_GMD),0) PESO_ATUAL" + CRLF +;
                         ", isnull(sum(SB8.B8_XPESOCO*(CASE WHEN SB8.B8_SALDO > 0 THEN B8_SALDO ELSE SB8.B8_QTDORI END))/sum((CASE WHEN SB8.B8_SALDO > 0 THEN B8_SALDO ELSE SB8.B8_QTDORI END))+(Z0O_DCESP*Z0O_GMD),0) PESO_FINAL  " + CRLF
                    EndIf
                 cSql += ", ISNULL(CASE WHEN Z0O_DINITR = ' '  THEN DTCOCHO.XDATACO WHEN Z0O_DINITR <> ' ' THEN Z0O_DINITR ELSE DTCOCHO.XDATACO END, DTCOCHO.XDATACO ) B8_XDATACO" + CRLF +;
                         ", case when DTCOCHO.XDATACO is null " + CRLF +;
                               " then '000' " + CRLF +;
                               " else right('000' + rtrim(cast(convert(int, convert(datetime, '" + DToS(dDataBase) + "', 112) - convert(datetime, ISNULL(CASE WHEN Z0O_DINITR = ' '  THEN DTCOCHO.XDATACO WHEN Z0O_DINITR <> ' ' THEN Z0O_DINITR ELSE DTCOCHO.XDATACO END, DTCOCHO.XDATACO), 112)+1) as varchar(3))), 3) " + CRLF +;
                           " end B8_DIASCO" + CRLF +;
                         ", isnull(Z0O_GMD,0) Z0O_GMD" + CRLF +;
                         ", isnull(Z0O_DCESP,0) Z0O_DCESP" + CRLF +;
                         ", AVG(B8_XPESOCO) B8_XPESOCO " + CRLF +;
                     " from " + RetSqlName("SB8") + " SB8" + CRLF +;
                     " join (" + CRLF +;
                           " select SB8.B8_X_CURRA" + CRLF +;
                                " , SB8.B8_LOTECTL" + CRLF +;
                                " , min(SB8.B8_XDATACO) XDATACO" + CRLF +;
                             " from " + RetSqlName("SB8") + " SB8" + CRLF +;
                            " where SB8.B8_FILIAL = '" + FWxFilial("SB8") + "'" + CRLF 
                        if mv_par01 == 1 // Lotes ativos
                             cSql += " and SB8.B8_SALDO > 0" + CRLF 
                        elseif mv_par01 == 2 // Lote Finalizados
                            cSql += " and SB8.B8_SALDO = 0" + CRLF 
                        EndIf
                      cSql += " and SB8.B8_XDATACO <> '" + Space(TamSX3("B8_XDATACO")[1]) + "'" + CRLF +;
                              " and SB8.D_E_L_E_T_ = ' '" + CRLF +;
                         " group by SB8.B8_X_CURRA" + CRLF +;
                                " , SB8.B8_LOTECTL" + CRLF +;
                          " ) DTCOCHO" + CRLF +;
                       " on SB8.B8_X_CURRA = DTCOCHO.B8_X_CURRA" + CRLF +;
                      " and SB8.B8_LOTECTL = DTCOCHO.B8_LOTECTL" + CRLF +;
                " left join " + RetSqlName("Z0O") + " Z0O" + CRLF +;
                       " on Z0O.Z0O_FILIAL = '" + FWxFilial("Z0O") + "'" + CRLF +;
                      " and Z0O.Z0O_LOTE   = SB8.B8_LOTECTL" + CRLF +;
                      " and Z0O.Z0O_FILIAL + Z0O.Z0O_LOTE + Z0O.Z0O_DATAIN in (" + CRLF +;
                            " select MAXZ0O.Z0O_FILIAL + MAXZ0O.Z0O_LOTE + max(MAXZ0O.Z0O_DATAIN)" + CRLF +;
                              " from " + RetSqlName("Z0O") + " MAXZ0O" + CRLF +;
                             " where MAXZ0O.Z0O_FILIAL = '" + FWxFilial("Z0O") + "'" + CRLF +;
                               " and MAXZ0O.D_E_L_E_T_ = ' '" + CRLF +;
                          " group by MAXZ0O.Z0O_FILIAL" + CRLF +;
                                 " , MAXZ0O.Z0O_LOTE" + CRLF +;
                          " )" + CRLF +;
                      " and Z0O.D_E_L_E_T_ = ' '" + CRLF +;
                " left join (" + CRLF +;
                           " select distinct Z0M_CODIGO, Z0M_DESCRI" + CRLF +;
                             " from " + RetSqlName("Z0M") + " Z0M" + CRLF +;
                            " where Z0M.Z0M_FILIAL = '" + FWxFilial("Z0M") + "'" + CRLF +;
                              " and Z0M.Z0M_VERSAO = (" + CRLF +;
                                                     " select max(Z0M_VERSAO)" + CRLF +;
                                                       " from " + RetSqlName("Z0M") + " MAXZ0M" + CRLF +;
                                                      " where MAXZ0M.Z0M_FILIAL = Z0M.Z0M_FILIAL" + CRLF +;
                                                        " and MAXZ0M.Z0M_CODIGO = Z0M.Z0M_CODIGO" + CRLF +;
                                                        " and MAXZ0M.D_E_L_E_T_ = ' '" + CRLF +;
                                                   " )" + CRLF +;
                              " and Z0M.D_E_L_E_T_ = ' '" + CRLF +;
                          " ) Z0M" + CRLF +;
                       " on Z0M.Z0M_CODIGO = Z0O.Z0O_CODPLA" + CRLF +;
                    " where SB8.B8_FILIAL = '" + FWxFilial("SB8") + "'" + CRLF +;
                      " and SB8.B8_X_CURRA <> '" + Space(TamSX3("B8_X_CURRA")[1]) + "'" + CRLF +;
                      " and SB8.D_E_L_E_T_ = ' '" + CRLF
    
    if mv_par01 == 1 // Lotes ativos
        cSql +=       " and SB8.B8_SALDO > 0" + CRLF
    elseif mv_par01 == 2 // Lote Finalizados
        cSql +=       " and SB8.B8_SALDO = 0" + CRLF
    endif
    
    cSql +=      " group by SB8.B8_X_CURRA" + CRLF +;
                         ", SB8.B8_LOTECTL" + CRLF +;
                         ", Z0M_DESCRI" + CRLF +;
                         ", Z0O_DATAIN" + CRLF +;
                         ", Z0O_DIAIN" + CRLF +;
                         ", Z0O_GMD" + CRLF +;
                         ", Z0O_DCESP" + CRLF +;
                         ", Z0O_DINITR " + CRLF +;
                         ", DTCOCHO.XDATACO" + CRLF +;
                 " order by SB8.B8_X_CURRA, SB8.B8_LOTECTL"
    
    If lDebug .and. lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador'
        MemoWrite(cPath + "VAPCPA07" + DtoS(dDataBase)+"_"+StrTran(SubS(Time(),1,5),":","") + ".sql" , cSql)
    EndIf
    
    if TCSqlExec(cSql) < 0
        Help(/*Descontinuado*/,/*Descontinuado*/,"LOTE X PL NUTRIC",/**/,"Ocorreu um erro ao carregar a lista de Lotes.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"Por favor, tente executar novamente e se o problema persistir entre em contato com o TI para averiguar o problema." })
        MemoWrite(cPath + "vapcpa07" + DtoS(dDataBase)+"_"+StrTran(SubS(Time(),1,5),":","") + ".log", "Ocorreu um erro ao carregar a lista de Lotes." + CRLF + TCSQLError())
    endif

else
    Help(/*Descontinuado*/,/*Descontinuado*/,"LOTE X PL NUTRIC",/**/,"Ocorreu um erro ao descartar a lista de Lotes.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"Por favor, tente executar novamente e se o problema persistir entre em contato com o TI para averiguar o problema." })
    MemoWrite(cPath + "vapcpa07" + DtoS(dDataBase)+"_"+StrTran(SubS(Time(),1,5),":","") + ".log", "Ocorreu um erro ao descartar a lista de Lotes." + CRLF + TCSQLError())
endif

if Type("oBrowse") <> 'U'
    oBrowse:nAt := nPos
    oBrowse:Refresh()
    oBrowse:ChangeTopBot()
endif

return nil


static Function MenuDef()
local aRotina := {} 

ADD OPTION aRotina TITLE OemToAnsi("Pesquisar")  ACTION "PesqBrw"             OPERATION 1 ACCESS 0 // "Pesquisar"
ADD OPTION aRotina TITLE OemToAnsi("Visualizar") ACTION "VIEWDEF.VAPCPA07"    OPERATION 2 ACCESS 0 // "Visualizar"
ADD OPTION aRotina TITLE OemToAnsi("Manuten��o") ACTION "u_vap07man"          OPERATION 4 ACCESS 0 // "Alterar"
ADD OPTION aRotina TITLE OemToAnsi("Parametros") ACTION "u_povoaBrw"          OPERATION 10 ACCESS 0 // ""

return aRotina


/*/{Protheus.doc} vap07man
Executa a chamada manual do execview da rotina. Usado para definir quais bot�es padr�o ser�o 
disponibilizados.
@author guima
@since 20/03/2019
@version 1.0
@return nil
@param cAlias, characters, Alias da tabela chamada pelo browse
@param nReg, numeric, Registro em que o browse est� posicionado
@param nOpc, numeric, Op��o executada (2=Visualiza��o, 3=Inclus�o, 4=Altera��o, 5=Excluis�o)
@type function
/*/
user function vap07man(cAlias, nReg, nOpc)
local aEnButt := {{.f., nil},;     // 1 - Copiar
                  {.f., nil},;     // 2 - Recortar
                  {.f., nil},;     // 3 - Colar
                  {.f., nil},;     // 4 - Calculadora
                  {.f., nil},;     // 5 - Spool
                  {.f., nil},;     // 6 - Imprimir
                  {.t., "Salvar"},;// 7 - Confirmar
                  {.t., "Sair"},;  // 8 - Cancelar
                  {.f., nil},;     // 9 - WalkTrhough
                  {.f., nil},;     // 10 - Ambiente
                  {.f., nil},;     // 11 - Mashup
                  {.t., nil},;     // 12 - Help
                  {.f., nil},;     // 13 - Formul�rio HTML
                  {.f., nil},;     // 14 - ECM
                  {.f., nil}}      // 15 - Salvar e Criar novo
    
    // if val((oTmpSB8:GetAlias())->B8_SALDO) > 0 
    if (oTmpSB8:GetAlias())->B8_SALDO > 0 
        FWExecView('Manuten��o', 'VAPCPA07', MODEL_OPERATION_UPDATE,, { || .T. },,,aEnButt )
    else
        FWExecView('Manuten��o', 'VAPCPA07', MODEL_OPERATION_UPDATE,, { || .T. },,,aEnButt )
        //Help(/*Descontinuado*/,/*Descontinuado*/,"Quantidade do lote � 0",/**/,"N�o � poss�vel alterar os planos nutricionais um lote com saldo 0.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"Para ver os planos nutricionais vinculados a esse lote utilize o bot�o visualizar." })
    endif
return nil

/*/{Protheus.doc} ModelDef
Define a regra de neg�cio no formato MVC
@author guima
@since 20/03/2019
@version 1.0
@return oModel, objeto do tipo MPFormModel contendo as regras do neg�cio

@type function
/*/
static Function ModelDef()
local oModel
local cCampo
local bCommit      :={|oModel| CommitZ0O(oModel)}
local bLoadFldSB8  :={|oModel    , lCopia| LoadSB8(oModel, lCopia)}
local bLoadGridZ0O :={|oModel    , lCopia| LoadZ0O(oModel, lCopia)}
local bLinePre     :={|oGridModel, nLin, cOperacao| LinePreZ0OGrid(oGridModel, nLin, cOperacao)}
// local bLinePost    :={|oGridModel, nLin| U_LinePosZ0OGrid(oGridModel, nLin)} // NAO FUNCIONOU, COLOQUEI NO X3_VALID
//local bGridPre := {|oGridModel, nLin, cOperacao| GridZ0OPre(oGridModel, nLin, cOperacao)}
local bGridPost    :={|oGridModel, nLin| GridZ0MValid(oGridModel, nLin)}
//local bPostValid := {|oModel| ModelValid(oModel)}
local oStruCab     := nil
local oStruDet     := nil
local aTrgCDPla    := {}
    
    oStruCab := FWFormStruct(1, "SB8", {|cField| cCampo := cField, aScan(aCposSB8, {|aMat| AllTrim(aMat) == AllTrim(cCampo)}) > 0}) 

    oStruDet := FWFormStruct(1, "Z0O", {|cField| cCampo := cField, aScan(aCposZ0O, {|aMat| AllTrim(aMat) == AllTrim(cCampo)}) > 0}) 
    //FwStruTrigger(<cDom >, <cCDom >, <cRegra >, [ lSeek ], <cAlias >, [ nOrdem ], [ cChave ], [ cCondic ], [ cSequen ])-> aRetorno
    // {"Z0O_CODPLA", "Z0O_DESPLA", "Z0O_DATAIN", "Z0O_DIAIN ", "Z0O_DATATR", "Z0O_GMD",    "Z0O_DCESP ", "Z0O_RENESP", "Z0O_PESO"}
    // Posicione("Z0M",1,FWxFilial("Z0M")+&("TMPZ0O->Z0O_CODPLA"),"Z0M_DESCRI")
    // Posicione("Z0M",1,FWxFilial("Z0M")+&("TMPZ0O->Z0O_CODPLA"),"Z0M_PESO")

    aTrgCDPla := aClone(FwStruTrigger("Z0O_CODPLA",;
                         "Z0O_DESPLA",;
                         "Z0M->Z0M_DESCRI",;
                          .t., "Z0O",;
                          1,;
                          "FWxFilial('Z0M')+M->Z0O_CODPLA", /*[cCondic]*/, "1"))
    oStruDet:AddTrigger(aTrgCDPla[1], aTrgCDPla[2], aTrgCDPla[3], aTrgCDPla[4])

    aTrgCDPla := aClone(FwStruTrigger("Z0O_CODPLA", "Z0O_PESO", "Z0M->Z0M_PESO", .f., "Z0O", /*[nOrdem]*/, /*[cChave]*/, /*[cCondic]*/, "2"))
    oStruDet:AddTrigger(aTrgCDPla[1], aTrgCDPla[2], aTrgCDPla[3], aTrgCDPla[4])

//  oModel := MpFormModel():New('U_VAPCPM01', /*bPreValid*/,               ,{|| .T.}/*Confirrmar*/, {|| .T.}/*Cancel*/)    
    oModel := MPFormModel():New("MDLVAPCPA07", /*bPreValid*/, /*bPostValid*/, bCommit, /*Cancel*/)  
    oModel:SetDescription(cDescri)    

    oModel:addFields('MdFieldSB8', /*cOwner*/, oStruCab, /*bPre*/, /*bPost*/, bLoadFldSB8)
    oModel:SetOnlyQuery('MdFieldSB8', .t.)
    oModel:addGrid('MdGridZ0O', 'MdFieldSB8', oStruDet, bLinePre, /* bLinePost */, /*bGridPre*/, bGridPost, bLoadGridZ0O)  

    // oModel:SetRelation( "GRIDABATE", {{"Z0Q_FILIAL", "Z0P_FILIAL"}, {"Z0Q_LOTE", "Z0P_LOTE"}, {"Z0Q_SEQUEN", "Z0P_SEQUEN"}}, Z0Q->(IndexKey(1)))
    // oModel:SetRelation('MdGridZ0O', {{"Z0O_FILIAL", xFilial("Z0O")}, {"Z0O_LOTE", "B8_LOTECTL"}}, Z0O->(IndexKey(1)))         
    oModel:SetPrimaryKey({"B8_X_CURRA", "B8_LOTECTL", "B8_PRODUTO"})

return oModel 

/*/{Protheus.doc} LoadSB8
Carrega os dados da tabela tempor�ria SB8, mostrados no cabe�alho. Usado pelo bloco de c�digo 
bLoadFldSB8. 

@author guima
@since 20/03/2019
@version 1.0

@return aDados, Array contendo os dados da a serem apresentados no cabe�alho da tela
@param oModel, object, Modelo de dados da rotina
@param lCopia, logical, indica se a op��o chamada trata-se da uma solicita��o de c�pia.
@type function
/*/
static function LoadSB8(oModel, lCopia)
local aDados := {}
local i, nLen
//aCposSB8 := {"B8_X_CURRA", "B8_LOTECTL", "B8_SALDO",   "B8_XPESOCO", "B8_XDATACO", "B8_GMD",     "B8_XRENESP", "B8_DIASCO "}

nLen := Len(oModel:oFormModelStruct:aFields)
for i := 1 to nLen
    AAdd(aDados, (cAliasTMP)->&(oModel:oFormModelStruct:aFields[i][3]))
next

return aDados


static function LoadZ0O(oFormGrid, lCopia)
local aArea      := GetArea()
local oView      := FWViewActive()
local aRet       := {}
local aDados     := {}
local i, nLen
Local nPos       := 0

Local _cSql      := ""
Local nPSexo     := 0
Local nPesoIni   := 0, nPPesoMedio := 0
Local nPTAMCAR   := 0
Local nPCMSPRE   := 0
Local nPGORDUR   := 0
Local nPFS       := 0
Local nPPESOPR   := 0
Local nPRaca     := 0
Local nPMCAPV    := 0
Local nPGMD      := 0
Local nPDCESP    := 0
Local nPDTABAT   := 0
Local nPDIARIA   := 0
Local dB8XDATACO := SToD("")
Local nB8SALDO   := 0


DbUseArea(.t., "TOPCONN", TCGenQry(,,;
                            " SELECT *" +; 
                            " FROM " + RetSqlName("Z0O") + " Z0O" +; 
                            " WHERE Z0O.Z0O_FILIAL = '" + FWxFilial("Z0O") + "'" +;
                              " AND Z0O.Z0O_LOTE   = '" + (cAliasTMP)->B8_LOTECTL + "'" +;
                              " AND Z0O.D_E_L_E_T_ = ' '" ;
                                                        ),"TMPZ0O", .f., .f.)
nLen := TMPZ0O->(fCount())
for i := 1 to nLen
    cCpo := FieldName(i)
    if !cCpo$"R_E_C_N_O_|R_E_C_D_E_L_|D_E_L_E_T_" .and. !TamSX3(cCpo)[3]$'CM' 
        TCSetField("TMPZ0O", cCpo, TamSX3(cCpo)[3], TamSX3(cCpo)[1], TamSX3(cCpo)[2])
    endif
next

If TMPZ0O->(Eof())
    TMPZ0O->(DbCloseArea())

    oView:oModel:lModify := .T.
    RecLock("Z0O", .T.)
        Z0O->Z0O_FILIAL := xFilial("Z0O")
        Z0O->Z0O_LOTE   := (cAliasTMP)->B8_LOTECTL
        Z0O->Z0O_CODPLA := GetMV("VA_CODPLA1",,"999999")
        Z0O->Z0O_DIAIN  := StrZero(1, TamSX3("Z0O_DIAIN")[1])
        Z0O->Z0O_DATAIN := MsDate() - GetMV("VA_CODPLA2",, 100)
    Z0O->(MsUnLock())

    DbUseArea(.t., "TOPCONN", TCGenQry(,,;
                                " SELECT *" +; 
                                " FROM " + RetSqlName("Z0O") + " Z0O" +; 
                                " WHERE Z0O.Z0O_FILIAL = '" + FWxFilial("Z0O") + "'" +;
                                " AND Z0O.Z0O_LOTE   = '" + (cAliasTMP)->B8_LOTECTL + "'" +;
                                " AND Z0O.D_E_L_E_T_ = ' '" ;
                                                            ),"TMPZ0O", .f., .f.)
    nLen := TMPZ0O->(fCount())
    for i := 1 to nLen
        cCpo := FieldName(i)
        if !cCpo$"R_E_C_N_O_|R_E_C_D_E_L_|D_E_L_E_T_" .and. !TamSX3(cCpo)[3]$'CM' 
            TCSetField("TMPZ0O", cCpo, TamSX3(cCpo)[3], TamSX3(cCpo)[1], TamSX3(cCpo)[2])
        endif
    next
EndIf

while !TMPZ0O->(Eof())

    aDados := {}
    nLen   := Len(oFormGrid:oFormModelStruct:aFields)
    for i := 1 to nLen  
        If oFormGrid:oFormModelStruct:aFields[i][3] $ "Z0O_DESPLA"
            AAdd(aDados, Iif(Inclui,"",Posicione("Z0M",1,FWxFilial("Z0M")+&("TMPZ0O->Z0O_CODPLA"),"Z0M_DESCRI")))
        elseif oFormGrid:oFormModelStruct:aFields[i][3] $ "Z0O_PESO"
            AAdd(aDados, 0 /* Iif(Inclui,"",Posicione("Z0M",1,FWxFilial("Z0M")+&("TMPZ0O->Z0O_CODPLA"),"Z0M_PESO")) */ )
        else
            AAdd(aDados, &("TMPZ0O->"+oFormGrid:oFormModelStruct:aFields[i][3]))
        endif
    next i

    /* MB : 28.07.2021
        -> Inclus�o de calculos e informa��o de MCal;
            -> Demanda sugerida pelo consultor Toninho;

        # INICIALIZA��O DOS CAMPOS
    */
    If(nPSexo:=aScan( oFormGrid:oFormModelStruct:aFields, { |x| x[3] == "Z0O_SEXO" } )) > 0
                       /* _cSql := " SELECT B1_X_SEXO, B8_XPESOCO, SUM(B8_SALDO) B8_SALDO "+CRLF+;
                                " FROM SB1010 SB1"+CRLF+;
                                " JOIN SB8010 SB8 ON B8_FILIAL = '" + xFilial("SB8") + "'"+CRLF+;
                                "              AND B1_COD = B8_PRODUTO"+CRLF+;
                                " 			   AND B8_LOTECTL = '" + AllTrim( &("TMPZ0O->Z0O_LOTE") ) + "'"+CRLF+;
                                " 			   AND SB1.D_E_L_E_T_ = ' ' "+CRLF+;
                                " 			   AND SB8.D_E_L_E_T_ = ' '"+CRLF+;
                                " GROUP BY B1_DESC, B1_X_SEXO, B8_XPESOCO"+CRLF+;
                                " ORDER BY 3 DESC" ; */
        DbUseArea(.t., "TOPCONN", TCGenQry(,,;
                       _cSql := " WITH DATACO AS ("+CRLF+;
                                "       SELECT	B8_FILIAL FILIAL , B8_LOTECTL LOTE, MIN(B8_XDATACO) DATACO "+CRLF+;
                                " 	    FROM	"+RetSqlName("SB8")+" "+CRLF+;
                                " 	    WHERE	B8_FILIAL  = '" + xFilial("SB8") + "' "+CRLF+;
                                " 	        AND B8_LOTECTL = '" + AllTrim( &("TMPZ0O->Z0O_LOTE") ) + "' "+CRLF+;
                                " 	        AND D_E_L_E_T_ = ' '"+CRLF+;
                                " 	    GROUP BY B8_FILIAL, B8_LOTECTL"+CRLF+;
                                " )"+CRLF+;
                                " SELECT SB8.B8_LOTECTL, B1_X_SEXO, SUM(CASE WHEN B8_SALDO > 0 THEN B8_SALDO ELSE B8_QTDORI END ) SALDO, D.DATACO B8_XDATACO, B8_XPESOCO"+CRLF+;
                                " FROM "+RetSqlName("SB8")+" SB8"+CRLF+;
                                " JOIN DATACO D   ON SB8.B8_FILIAL = D.FILIAL"+CRLF+;
                                " 				 AND SB8.B8_LOTECTL = D.LOTE"+CRLF+;
                                " JOIN "+RetSqlName("SB1")+" B1 ON B1_COD = B8_PRODUTO "+CRLF+;
			                    "         AND B1.D_E_L_E_T_ = ' ' "+CRLF+;
                                " GROUP BY SB8.B8_LOTECTL, B1_X_SEXO, DATACO, B8_XPESOCO"+CRLF+;
                                " ORDER BY 3 DESC";
                                        ),"TMPsexo", .f., .f.)
        if (!TMPsexo->(Eof()))
            If Empty( aDados[nPSexo] )
                aDados[nPSexo] := Left(TMPsexo->B1_X_SEXO,1)
            EndIf
            nPesoIni       := TMPsexo->B8_XPESOCO
            dB8XDATACO     := TMPsexo->B8_XDATACO
            While (!TMPsexo->(Eof()))
                nB8SALDO   += TMPsexo->SALDO
                TMPsexo->(DbSkip())
            EndDo
        EndIf
        TMPsexo->(DbCloseArea())
    EndIf

    If (nPTAMCAR:=aScan( oFormGrid:oFormModelStruct:aFields, { |x| x[3] == "Z0O_TAMCAR" } )) > 0;
        .AND. Empty( aDados[nPTAMCAR] )
        // AAdd(aDados, Randomize( 4, 8) )
        DO CASE
            CASE (nPesoIni/30) <= 11
                aDados[nPTAMCAR] := 4
            CASE (nPesoIni/30) <= 13
                aDados[nPTAMCAR] := 5
            CASE (nPesoIni/30) <= 15
                aDados[nPTAMCAR] := 6
            CASE (nPesoIni/30) <= 17
                 aDados[nPTAMCAR] := 7
            OTHERWISE
                aDados[nPTAMCAR] := 8
        ENDCASE
    EndIf

    If (nPCMSPRE:=aScan( oFormGrid:oFormModelStruct:aFields, { |x| x[3] == "Z0O_CMSPRE" } )) > 0;
        .AND. Empty( aDados[nPCMSPRE] )
        aDados[nPCMSPRE] := 2.2
    EndIf

    If (nPGORDUR:=aScan( oFormGrid:oFormModelStruct:aFields, { |x| x[3] == "Z0O_GORDUR" } )) > 0;
        .AND. Empty( aDados[nPGORDUR] )
        aDados[nPGORDUR] := 27
    EndIf

    If (nPFS:=aScan( oFormGrid:oFormModelStruct:aFields, { |x| x[3] == "Z0O_FS" } )) > 0;
        .AND. Empty( aDados[nPFS] )
        // aDados[nPFS] := iIf( AllTrim(Upper(aDados[nPSexo]))=="MACHO",-0.12,0) + (1.33+0.0036 * (nPesoIni*0.96))
        aDados[nPFS] := iIf( Left(Upper(aDados[nPSexo]),1)=="M",-0.12,0) + (1.33+(0.0036 * (nPesoIni*0.96)))
    EndIf

    If (nPPESOPR:=aScan( oFormGrid:oFormModelStruct:aFields, { |x| x[3] == "Z0O_PESOPR" } )) > 0;
        .AND. Empty( aDados[nPPESOPR] )
        // Peso Final Previsto
        If( Left(Upper(aDados[nPSexo]),1)=="F" )
            aDados[nPPESOPR] := (;
                                        551.5-0.2482*(nPesoIni*0.96)+(0.00119*((nPesoIni*0.96)^2))-(39.84*aDados[nPFS]);
                                );
                                *;
                                ( ;
                                    (aDados[nPGORDUR]/100) / (28/100);
                                );
                                +;
                                (;
                                    iIf(aDados[nPTAMCAR]==4,;
                                            -33.2, ;
                                            iIf(aDados[nPTAMCAR]==5,;
                                                0,;
                                                iIf(aDados[nPTAMCAR]==6,;
                                                    33.2, ;
                                                    0);
                                            );
                                    );
                                )
        Else // sexo = MACHO
            aDados[nPPESOPR] := (;
                                    (;
                                        (509.6+(0.4697*(nPesoIni*0.96)-(46.54*aDados[nPFS])));
                                    );
                                    * ;
                                    ( ;
                                        (aDados[nPGORDUR]/100) / (28/100);
                                    );
                                );
                                +;
                                (;
                                    iIf(aDados[nPTAMCAR]==3,;
                                        -66.4, ;
                                        iIf(aDados[nPTAMCAR]==4,;
                                            -33.2, ;
                                            iIf(aDados[nPTAMCAR]==5,;
                                                0,;
                                                iIf(aDados[nPTAMCAR]==6,;
                                                    33.2, ;
                                                    iIf(aDados[nPTAMCAR]==7,;
                                                        66.4, ;
                                                        iIf(aDados[nPTAMCAR]==8,;
                                                            99.6,;
                                                            0);
                                                    );
                                                );
                                            );
                                        );
                                    );
                                )
        EndIf
        // Peso Final Previsto
    EndIf

    If (nPPesoMedio:=aScan( oFormGrid:oFormModelStruct:aFields, { |x| x[3] == "Z0O_PESO" } ))>0;
        .AND. Empty( aDados[nPPesoMedio] )
        aDados[nPPesoMedio] := (aDados[nPPESOPR] + (nPesoIni * 0.96) ) / 2
    EndIf

    If (nPos:=aScan( oFormGrid:oFormModelStruct:aFields, { |x| x[3] == "Z0O_MCALPR" } )) > 0;
        .AND. Empty( aDados[nPos] )
        DbUseArea(.t., "TOPCONN", TCGenQry(,,;
                                 _cSql := " SELECT distinct " + cValToChar(aDados[nPPesoMedio] ) +;
                                          " * G1_ENERG * (" + cValToChar(aDados[nPCMSPRE]) + "/100) AS MEGACAL"+CRLF+;
                                          " FROM "+RetSqlName("SG1")+" "+CRLF+;
                                          " WHERE G1_FILIAL = '" + xFilial('SG1') + "' "+CRLF+;
                                          "   AND G1_COD = '" + GetMV("VA_PCP07MC",,'FINAL') + "'"+CRLF+;
                                          "   AND D_E_L_E_T_ = ' '";
                                    ),"TMPmgCal", .f., .f.)
        MEMOWRITE("C:\TOTVS_RELATORIOS\vaPCPa07_Z0O_MCALPR.SQL", _cSql)
        if (!TMPmgCal->(Eof()))
            aDados[nPos] := TMPmgCal->MEGACAL
        EndIf
        TMPmgCal->(DbCloseArea())    
    EndIf

    If (nPRaca:=aScan( oFormGrid:oFormModelStruct:aFields, { |x| x[3] == "Z0O_RACA" } )) > 0;
        .AND. Empty( aDados[nPRaca] )
                // VERIFICA SE O LOTE VEIO A PARTIR DA Z0F E PEGA A RA?A DA Z0F
        /*
            ARTHUR TOSHIO 
        */
        DbUseArea(.t., "TOPCONN", TCGenQry(,,;
                    _cSqlR := " SELECT Z0F_LOTE, Z0F_RACA, COUNT(Z0F_SEQ) QTDE " +CRLF +; 
                               " FROM "+ RetSqlName("Z0F") +" Z0F " +CRLF +;
                              " WHERE Z0F_FILIAL = '"+ xFilial("Z0F") + "' " +CRLF +;
                                " AND Z0F_LOTE = '" + AllTrim( &("TMPZ0O->Z0O_LOTE") ) + "'  " +CRLF +;
                                " AND D_E_L_E_T_ = ' ' " +CRLF +;
                                " GROUP BY Z0F_LOTE, Z0F_RACA " +CRLF +;
                                " ORDER BY 3 DESC, 2 DESC";
                               ),"TMPQryR", .F., .F.)
        MEMOWRITE("C:\TOTVS_RELATORIOS\vaPCPa07_Z0O_Z0FRACA.SQL", _cSqlR)

        // SE RETORNAR + DE 1, CONSIDERAR O QUE TEM MAIOR QUANTIDADE
        DbUseArea(.t., "TOPCONN", TCGenQry(,,;
                    _cSql := " SELECT		B8_LOTECTL, B1_XRACA, SUM(B8_SALDO) QTDE"+CRLF+;
                            " FROM "+RetSqlName("SB8")+" B8"+CRLF+;
                            " JOIN "+RetSqlName("SB1")+" B1 ON B1_COD = B8_PRODUTO "+CRLF+;
                            "             AND B1.D_E_L_E_T_ = ' ' "+CRLF+;
                            " WHERE	 B8_FILIAL = " +xFilial("SB8") + " AND B8_LOTECTL ='" + AllTrim( &("TMPZ0O->Z0O_LOTE") ) + "' AND "+CRLF+;
                            "             B8.D_E_L_E_T_ = ' ' "+CRLF+;
                            " GROUP BY	B8_LOTECTL, "+CRLF+;
                            "             B1_XRACA"+CRLF+;
                            " ORDER BY 3 DESC";
                    ),"TMPQry", .F., .F.)
        MEMOWRITE("C:\TOTVS_RELATORIOS\vaPCPa07_Z0O_MCALPR.SQL", _cSql)
        if (!TMPQry->(Eof()))
           If (!TMPQryR->(Eof()))
                aDados[nPRaca] := TMPQryR->Z0F_RACA
            Else 
                aDados[nPRaca] := TMPQry->B1_XRACA
            EndIf
        EndIf
        TMPQryR->(DbCloseArea())  
        TMPQry->(DbCloseArea())    
    EndIf

    If (nPMCAPV:=aScan( oFormGrid:oFormModelStruct:aFields, { |x| x[3] == "Z0O_MCAPV" } )) > 0;
        .AND. Empty( aDados[nPMCAPV] )
        If aDados[nPRaca] == "RA�A"
            aDados[nPMCAPV] := 6.23
        Else
            If Left(Upper(aDados[nPSexo]),1)=="M"
                aDados[nPMCAPV] := 6.21
            Else
                aDados[nPMCAPV] := 6.25
            EndIf
        EndIf
    EndIf

    If (nPGMD:=aScan( oFormGrid:oFormModelStruct:aFields, { |x| x[3] == "Z0O_GMD" } )) > 0;
        .AND. Empty( aDados[nPGMD] )
        If Left(Upper(aDados[nPSexo]),1)=="F" // =SE(SEXO =""F"";-0,0000011*(Z0O_MCALPV)^2+27,508*(Z0O_MCALPV/100)-0,47;
            aDados[nPGMD] := -0.0000011*( (aDados[nPMCAPV]/100) )^2 + 27.508 * (aDados[nPMCAPV]/100) - 0.47
        Else
            If aDados[nPRaca] == "CRUZADOS" // SE(RA�A=""CRUZADOS"";-74,073*(Z0O_MCALPV/100)^2+36,573*(O4)-0,6323;
                aDados[nPGMD] := -74.073*(aDados[nPMCAPV]/100)^2+36.573*(aDados[nPMCAPV]/100)-0.6323
            ElseIf aDados[nPRaca] == "ANGUS" // SE(RA�A=""ANGUS"";(-147,35*(Z0O_MCALPV/100)^2)+56,249*(Z0O_MCALPV/100)-1,2206;
                aDados[nPGMD] := (-147.35*(aDados[nPMCAPV]/100)^2)+56.249*(aDados[nPMCAPV]/100)-1.2206
            Else
                aDados[nPGMD] := (-74.073*((aDados[nPMCAPV]/100)^2))+36.573*(aDados[nPMCAPV]/100)-0.5623
            EndIf
        EndIf
    EndIf
    
    If (nPDCESP:=aScan( oFormGrid:oFormModelStruct:aFields, { |x| x[3] == "Z0O_DCESP" } )) > 0;
        .AND. Empty( aDados[nPDCESP] )
        //               = (Z0O_PESOPR - B8_XPESOCO) / Z0O_GMD
        aDados[nPDCESP] := NoRound( ( aDados[nPPESOPR] - nPesoIni ) / aDados[nPGMD], 0 )
    EndIf

    If (nPDTABAT:=aScan( oFormGrid:oFormModelStruct:aFields, { |x| x[3] == "Z0O_DTABAT" } )) > 0;
        .AND. Empty( aDados[nPDTABAT] )
                        // B8_XDATACO + Z0O_DCESP
        aDados[nPDTABAT] := sToD(dB8XDATACO) + aDados[nPDCESP]
    EndIf

    If (nPDIARIA:=aScan( oFormGrid:oFormModelStruct:aFields, { |x| x[3] == "Z0O_DIARIA" } )) > 0;
        .AND. Empty( aDados[nPDIARIA] )
                    // SUM(B8_SALDO) X Z0O_DCESP
        aDados[nPDIARIA] := nB8SALDO * aDados[nPDCESP]
    EndIf

    AAdd(aRet, {TMPZ0O->R_E_C_N_O_, aClone(aDados)})
    TMPZ0O->(DbSkip())
end
TMPZ0O->(DbCloseArea())

if oView:IsActive()
    oView:Refresh("VwGridZ0O")
    oView:Refresh("VwFieldSB8")
endif
if !Empty(aArea)
    RestArea(aArea)
endif
return aRet

/*/{Protheus.doc} GridZ0MValid
Valida o modelo de dados. Usado pelo bloco de c�digo bPostValid

@author guima
@since 20/03/2019
@version 1.0
@return Logic, identifica se o modelo � v�lido
@param oModel, object, descricao
@type function
/*/
static function GridZ0MValid(oGridModel)
local lRet := .t.
local i, j, nLen 

if !oGridModel:IsEmpty()
    nLen := oGridModel:Length()
    for i := 1 to nLen
        if !oGridModel:IsDeleted(i)
            if Empty(oGridModel:GetValue("Z0O_CODPLA", i))
                Help(/*Descontinuado*/,/*Descontinuado*/,"Z0O_CODPLA",/**/,"O 'Plano Nutric' � obrigat�rio.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"Por favor preencha o plano nutricional na linha " + AllTrim(Str(i)) + " com um valor v�lido." + CRLF + "<F3 Dispon�vel>" })
                lRet := .f.
                exit
            elseif Empty(oGridModel:GetValue("Z0O_DIAIN", i))
                Help(/*Descontinuado*/,/*Descontinuado*/,"Z0O_DIAIN",/**/,"O 'Dia Inicio' � obrigat�rio.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"Por favor preencha o dia de inicio na linha " + AllTrim(Str(i)) + " com um valor v�lido." + CRLF + "<F3 Dispon�vel>" })
                lRet := .f.
                exit
            elseif Empty(oGridModel:GetValue("Z0O_DATAIN", i))
                Help(/*Descontinuado*/,/*Descontinuado*/,"Z0O_DATAIN",/**/,"A 'Data Inicio' � obrigat�ria.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"Por favor preencha a data de inicio do trato na linha " + AllTrim(Str(i)) + " com um valor v�lido." })
                lRet := .f.
                exit
            elseif i <> nLen .and. Empty(oGridModel:GetValue("Z0O_DATATR", i))
                Help(/*Descontinuado*/,/*Descontinuado*/,"Z0O_DATATR",/**/,"A 'Data Termino' � obrigat�ria exceto na ultima linha.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"Por favor preencha a data de termino na linha " + AllTrim(Str(i)) + " com um valor v�lido." })
                lRet := .f.
                exit
            endif
        endif
    next
    if lRet
        for i := 1 to nLen
            for j := 1 to nLen
                if i <> j .and. !oGridModel:IsDeleted(i) .and. !oGridModel:IsDeleted(j) 
                    if i == nLen .and. Empty(oGridModel:GetValue("Z0O_DATATR", i))
                        if !(oGridModel:GetValue("Z0O_DATAIN", j) < oGridModel:GetValue("Z0O_DATAIN", i) .and. oGridModel:GetValue("Z0O_DATATR", j) < oGridModel:GetValue("Z0O_DATAIN", i))
                            Help(/*Descontinuado*/,/*Descontinuado*/,"Intervalo inv�lido",/**/,"Quando o �ltimo intervalo for aberto, todas os demais intervalos devem ser inferiores a data de inicio do �ltimo intervalo.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"Por favor preencha a data de inicio e termino na linha " + AllTrim(Str(i)) + " com um valores v�lidos." })
                            lRet := .f.
                            exit
                        endif
                    elseif j == nLen .and. Empty(oGridModel:GetValue("Z0O_DATATR", j))
                        if !(oGridModel:GetValue("Z0O_DATAIN", i) < oGridModel:GetValue("Z0O_DATAIN", j) .and. oGridModel:GetValue("Z0O_DATATR", i) < oGridModel:GetValue("Z0O_DATAIN", j))
                            Help(/*Descontinuado*/,/*Descontinuado*/,"Intervalo inv�lido",/**/,"Quando o �ltimo intervalo for aberto, todas os demais intervalos devem ser inferiores a data de inicio do �ltimo intervalo.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"Por favor preencha a data de inicio e termino na linha " + AllTrim(Str(i)) + " com um valores v�lidos." })
                            lRet := .f.
                            exit
                        endif
                    else
                        if !((oGridModel:GetValue("Z0O_DATAIN", j) < oGridModel:GetValue("Z0O_DATAIN", i) .and. oGridModel:GetValue("Z0O_DATATR", j) < oGridModel:GetValue("Z0O_DATAIN", i)) .or. (oGridModel:GetValue("Z0O_DATAIN", j) > oGridModel:GetValue("Z0O_DATATR", i) .and. oGridModel:GetValue("Z0O_DATATR", j) > oGridModel:GetValue("Z0O_DATATR", i)))    
                            Help(/*Descontinuado*/,/*Descontinuado*/,"Intervalo inv�lido",/**/,"O itervalo de datas.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"Por favor preencha a data de termino na linha " + AllTrim(Str(i)) + " com um valor v�lido." })
                            lRet := .f.
                            exit
                        endif
                    endif
                endif
            next
        next
    endif
endif

return lRet

/* MB 29.07.2021
    -> Validar ap�s sair do campo */
User Function LinePosZ0OGrid(_cCampo, nValor1, lDigitado)
local lRet        := .T.
local aArea       := GetArea()
Local oModel      := FWModelActive()
Local oGridModel  := oModel:GetModel("MdGridZ0O")
Local nPesoIni    := 0
Local nAux        := 0
Default _cCampo   := StrTran( ReadVar(), "M->", "" )
Default nValor1   := 0
Default lDigitado := .T. // Digitado ou Automatico

    DO CASE
        CASE _cCampo == "Z0O_TAMCAR"
            U_LinePosZ0OGrid( "Z0O_PESOPR" )
        CASE _cCampo == "Z0O_GORDUR"
            U_LinePosZ0OGrid( "Z0O_PESOPR" )
        CASE _cCampo == "Z0O_CMSPRE"
            U_LinePosZ0OGrid( "Z0O_PESOPR" )
        CASE _cCampo == "Z0O_RACA"
            U_LinePosZ0OGrid( "Z0O_PESOPR" )        
        CASE _cCampo == "Z0O_PESOPR"

            // Peso Inicial
            DbUseArea(.t., "TOPCONN", TCGenQry(,,;
                           _cSql := " SELECT B1_X_SEXO, B8_XPESOCO, SUM(B8_SALDO) B8_SALDO "+CRLF+;
                                    " FROM "+RetSqlName("SB1")+" SB1"+CRLF+;
                                    " JOIN "+RetSqlName("SB8")+" SB8 ON B8_FILIAL = '" + xFilial("SB8") + "'"+CRLF+;
                                    "              AND B1_COD = B8_PRODUTO"+CRLF+;
                                    " 			   AND B8_LOTECTL = '" + AllTrim( oModel:GetModel("MdFieldSB8"):GetValue("B8_LOTECTL") ) + "'"+CRLF+;
                                    " 			   AND SB1.D_E_L_E_T_ = ' ' "+CRLF+;
                                    " 			   AND SB8.D_E_L_E_T_ = ' '"+CRLF+;
                                    " GROUP BY B1_DESC, B1_X_SEXO, B8_XPESOCO"+CRLF+;
                                    " ORDER BY 3 DESC" ;
                        ),"TMPsexo", .f., .f.)
            if (!TMPsexo->(Eof()))
                nPesoIni       := TMPsexo->B8_XPESOCO
            EndIf
            TMPsexo->(DbCloseArea())

            If( Left(oGridModel:GetValue("Z0O_SEXO"),1)=="F" )
                nAux := (;
                            551.5-0.2482*(nPesoIni*0.96)+(0.00119*((nPesoIni*0.96)^2))-(39.84*oGridModel:GetValue("Z0O_FS"));
                        );
                        *;
                        ( ;
                            (oGridModel:GetValue("Z0O_GORDUR")/100) / (28/100);
                        );
                        +;
                        (;
                            iIf(oGridModel:GetValue("Z0O_TAMCAR")==4,;
                                -33.2, ;
                                iIf(oGridModel:GetValue("Z0O_TAMCAR")==5,;
                                    0,;
                                    iIf(oGridModel:GetValue("Z0O_TAMCAR")==6,;
                                        33.2, ;
                                        0);
                                );
                            );
                        )
            Else // sexo = MACHO
                nAux := (;
                            (;
                                (509.6+(0.4697*(nPesoIni*0.96)-(46.54*oGridModel:GetValue("Z0O_FS"))));
                            );
                            * ;
                            ( ;
                                (oGridModel:GetValue("Z0O_GORDUR")/100) / (28/100);
                            );
                        );
                        +;
                        (;
                            iIf(oGridModel:GetValue("Z0O_TAMCAR")==3,;
                                -66.4, ;
                                iIf(oGridModel:GetValue("Z0O_TAMCAR")==4,;
                                    -33.2, ;
                                    iIf(oGridModel:GetValue("Z0O_TAMCAR")==5,;
                                        0,;
                                        iIf(oGridModel:GetValue("Z0O_TAMCAR")==6,;
                                            33.2, ;
                                            iIf(oGridModel:GetValue("Z0O_TAMCAR")==7,;
                                                66.4, ;
                                                iIf(oGridModel:GetValue("Z0O_TAMCAR")==8,;
                                                    99.6,;
                                                    0);
                                            );
                                        );
                                    );
                                );
                            );
                        )
            EndIf        
            oGridModel:SetValue("Z0O_PESOPR", nAux)
            
            U_LinePosZ0OGrid( "Z0O_PESO", nPesoIni )

        CASE _cCampo == "Z0O_PESO"
            nAux := (oGridModel:GetValue("Z0O_PESOPR") + (nValor1 * 0.96) ) / 2
            oGridModel:SetValue("Z0O_PESO", nAux)

            U_LinePosZ0OGrid( "Z0O_MCALPR" )

        CASE _cCampo == "Z0O_MCALPR"
            DbUseArea(.t., "TOPCONN", TCGenQry(,,;
                                _cSql := " SELECT distinct " + cValToChar(oGridModel:GetValue("Z0O_PESO")) +;
                                         " * G1_ENERG * (cast(" + cValToChar(oGridModel:GetValue("Z0O_CMSPRE")) + " as float)/100) AS MEGACAL"+CRLF+;
                                         " FROM "+ RetSqlName("SG1") +" "+CRLF+;
                                         " WHERE G1_FILIAL = '" + xFilial('SG1') + "' "+CRLF+;
                                         "   AND G1_COD = '" + GetMV("VA_PCP07MC",,'FINAL') + "'"+CRLF+;
                                         "   AND D_E_L_E_T_ = ' '";
                                            ),"TMPmgCal", .F., .F.)
            MEMOWRITE("C:\TOTVS_RELATORIOS\vaPCPa07_Z0O_MCALPR.SQL", _cSql)
            if (!TMPmgCal->(Eof()))
                nAux := TMPmgCal->MEGACAL
                oGridModel:SetValue("Z0O_MCALPR", nAux)
            EndIf
            TMPmgCal->(DbCloseArea())    
        
        CASE _cCampo == "Z0O_GMD"

            // Atualizar o campo: Z0O_DCESP
          
            nPesoIni := 0
            // Peso Inicial
            DbUseArea(.t., "TOPCONN", TCGenQry(,,;
                           _cSql := " SELECT B1_X_SEXO, B8_XPESOCO, SUM(B8_SALDO) B8_SALDO "+CRLF+;
                                    " FROM "+RetSqlName("SB1")+" SB1"+CRLF+;
                                    " JOIN "+RetSqlName("SB8")+" SB8 ON B8_FILIAL = '" + xFilial("SB8") + "'"+CRLF+;
                                    "              AND B1_COD = B8_PRODUTO"+CRLF+;
                                    " 			   AND B8_LOTECTL = '" + AllTrim( oModel:GetModel("MdFieldSB8"):GetValue("B8_LOTECTL") ) + "'"+CRLF+;
                                    " 			   AND SB1.D_E_L_E_T_ = ' ' "+CRLF+;
                                    " 			   AND SB8.D_E_L_E_T_ = ' '"+CRLF+;
                                    " GROUP BY B1_DESC, B1_X_SEXO, B8_XPESOCO"+CRLF+;
                                    " ORDER BY 3 DESC" ;
                        ),"TMPpesoIni", .f., .f.)
            if (!TMPpesoIni->(Eof()))
                nPesoIni       := TMPpesoIni->B8_XPESOCO
            EndIf
            TMPpesoIni->(DbCloseArea())

            // GMD -> 
            //      Dias de Cocho = (Peso Projetado -Peso Inicial ) / GMD Esperado
            nAux := ( oGridModel:GetValue("Z0O_PESOPR") - nPesoIni ) / oGridModel:GetValue("Z0O_GMD")
            oGridModel:LoadValue("Z0O_DCESP", nAux)
            
            U_LinePosZ0OGrid( "Z0O_DTABAT" )

        //CASE _cCampo == "Z0O_DCESP"
        CASE _cCampo == "Z0O_DTABAT"
            // Data de Abate = Data inicial + dias de cocho
            xAux := oGridModel:GetValue("Z0O_DATAIN") + Round(oGridModel:GetValue("Z0O_DCESP"),0)
            oGridModel:LoadValue("Z0O_DTABAT", xAux)

    ENDCASE

if !Empty(aArea)
    RestArea(aArea)
endif
return lRet

static function LinePreZ0OGrid(oGridModel, nLin, cOpc)
local aArea := GetArea()
local cSql := ""
local i, nLen
local oModel := nil
local dDiaIni, dDiaFim
local lRet := .t. 

if cOpc == "DELETE"
    if !oGridModel:isInserted(nLin) .or. nLin <> oGridModel:Length() .or. !Empty(oGridModel:GetValue("Z0O_CODPLA"))
        oModel := FWModelActive()
        cSql := " select count(Z05_FILIAL) nQtdReg" +;
                  " from " + RetSqlName("Z05") + " Z05" +;
                 " where Z05.Z05_FILIAL = '" + FWxFilial("Z05") + "'" +;
                   " and Z05.Z05_LOTE   = '" + oModel:GetModel('MdFieldSB8'):GetValue("B8_LOTECTL") + "'" +;
                   " and Z05.D_E_L_E_T_ = ' '"
        if Empty(oGridModel:GetValue("Z0O_DATATR"))
            cSql += " and Z05.Z05_DATA   >= '" + DToS(oGridModel:GetValue("Z0O_DATAIN")) + "'" 
        else
            cSql += " and Z05.Z05_DATA   between '" + DToS(oGridModel:GetValue("Z0O_DATAIN")) + "' and '" + DToS(oGridModel:GetValue("Z0O_DATATR")) + "'" 
        endif
        
        DbUseArea(.t., "TOPCONN", TCGenQry(,,cSql), "TMPZ05", .f., .f.)
            if TMPZ05->nQtdReg > 0
                Help(,, "N�o � poss�vel excluir",, "Existem tratos que utilizam esse plano nutricional para esse lote.", 1, 0,,,,,, {"Para excluir esse plano nutricional � necess�rio excluir os tratos que o utilizam."})
                lRet := .f.
            endif
        TMPZ05->(DbCloseArea())
    endif
elseif cOpc == "UNDELETE"
    nLen := oGridModel:Length()
    dDiaIni := oGridModel:GetValue("Z0O_DATAIN")
    dDiaFim := oGridModel:GetValue("Z0O_DATATR")

    for i := 1 to nLen
        if dDiaIni >= oGridModel:GetValue("Z0O_DATAIN", i) .and. (!Empty(oGridModel:GetValue("Z0O_DATATR", i)) .or. dDiaIni <= oGridModel:GetValue("Z0O_DATATR", i))
            Help(,, "N�o � poss�vel recuperar o registro",, "A data de inicio da linha deletada se confunde com o intervalo presente na linha " + AllTrim(Str(i)) + ".", 1, 0,,,,,, {"N�o � poss�vel restaurar o registro."})
            lRet := .f.
            exit
        endif
        if dDiaFim >= oGridModel:GetValue("Z0O_DATAIN", i) .and. (!Empty(oGridModel:GetValue("Z0O_DATATR", i)) .or. dDiaFim <= oGridModel:GetValue("Z0O_DATATR", i))
            Help(,, "N�o � poss�vel recuperar o registro",, "A data de termino da linha deletada se confunde com o intervalo presente na linha " + AllTrim(Str(i)) + ".", 1, 0,,,,,, {"N�o � poss�vel restaurar o registro."})
            lRet := .f.
            exit
        endif 
    next
endif

if !Empty(aArea)
    RestArea(aArea)
endif
return lRet

static function ViewDef()
local oModel := nil 
local cCampo 
local oStrCab := nil 
local oStrDet := nil
local oView 

    oModel := ModelDef()
    oMdField := oModel:GetModel('MdFieldSB8')
    oMdField:oFormModelStruct:SetProperty("*", MODEL_FIELD_WHEN, {||.f.})
    oMdField:oFormModelStruct:SetProperty("*", MODEL_FIELD_OBRIGAT, .f.)

    // oMdGrid := oModel:GetModel('MdGridZ0O')
    oStrCab := FWFormStruct(2, "SB8", {|cField| cCampo := cField, aScan(aCposSB8, {|aMat| AllTrim(aMat) == AllTrim(cCampo)}) > 0})
    oStrDet := FWFormStruct(2, "Z0O", {|cField| cCampo := cField, aScan(aCposZ0O, {|aMat| AllTrim(aMat) == AllTrim(cCampo)}) > 0})

    oView := FWFormView():New()  
    oView:SetModel(oModel)
    oView:AddField('VwFieldSB8', oStrCab, 'MdFieldSB8')  
    oView:AddGrid('VwGridZ0O', oStrDet, 'MdGridZ0O')  

    oView:CreateHorizontalBox( 'CABECALHO', 15)  
    oView:CreateHorizontalBox( 'ITENS'    , 85)  

    oView:SetOwnerView('VwFieldSB8', 'CABECALHO')  
    oView:SetOwnerView('VwGridZ0O', 'ITENS')   

    oView:EnableTitleView('VwFieldSB8', "Dados do Lote")
    oView:EnableTitleView('VwGridZ0O', "Plano Nutricional")

    //oStrDet:RemoveField("Z0O_FILIAL")

return oView

/*/{Protheus.doc} CommitZ0M
Grava os dados na tabela ZM0

@author jrscatolon@jrscatolon.com.br
@since 22/02/2019
@version 1.0
@param oModel, object, Modelo de dados da tela
/*/
static function CommitZ0O(oModel)
local aArea := GetArea()
local nOperation := oModel:GetOperation()
local lRet := .t.
local oFieldModel, oGridModel
local i, j, nLen
local cQuery := ""

DbSelectArea("Z0M")
DbSetOrder(1) // Z0M_FILIAL+Z0M_CODIGO+Z0M_VERSAO+Z0M_DIA+Z0M_TRATO

if nOperation == MODEL_OPERATION_UPDATE
    oFieldModel := oModel:GetModel('MdFieldSB8')
    oGridModel :=  oModel:GetModel('MdGridZ0O')

    if GetMV("VA_PCPA07U",,.t.)
        cQuery := " update " + RetSqlName("Z0O") +;
                     " set D_E_L_E_T_ = '*'"
    else
        cQuery := " delete from " + RetSqlName("Z0O")
    endif

   cQuery += " where Z0O_FILIAL = '" + FWxFilial("Z0O") + "'" +;
               " and Z0O_LOTE   = '" + oFieldModel:GetValue("B8_LOTECTL") + "'" +;
               " and D_E_L_E_T_ = ' '" ;

    begin transaction
    TCSqlExec(cQuery)

    nLen := oGridModel:Length()
    for i := 1 to nLen
        oGridModel:GoLine(i)
        if !oGridModel:IsDeleted()
            RecLock("Z0O", .t.)
               Z0O->Z0O_FILIAL := FWxFilial("Z0O")
               Z0O->Z0O_LOTE   := oFieldModel:GetValue("B8_LOTECTL")
               Z0O->Z0O_CODPLA := oGridModel:GetValue("Z0O_CODPLA")
               Z0O->Z0O_DIAIN  := oGridModel:GetValue("Z0O_DIAIN")
               Z0O->Z0O_DATAIN := oGridModel:GetValue("Z0O_DATAIN")
               Z0O->Z0O_DATATR := oGridModel:GetValue("Z0O_DATATR")
               Z0O->Z0O_GMD    := oGridModel:GetValue("Z0O_GMD")
               Z0O->Z0O_DCESP  := oGridModel:GetValue("Z0O_DCESP")
               Z0O->Z0O_RENESP := oGridModel:GetValue("Z0O_RENESP")
               Z0O->Z0O_RACA   := oGridModel:GetValue("Z0O_RACA")
               Z0O->Z0O_SEXO   := oGridModel:GetValue("Z0O_SEXO")
               Z0O->Z0O_TAMCAR := oGridModel:GetValue("Z0O_TAMCAR")
               Z0O->Z0O_CMSPRE := oGridModel:GetValue("Z0O_CMSPRE")
               Z0O->Z0O_GORDUR := oGridModel:GetValue("Z0O_GORDUR")
               Z0O->Z0O_FS     := oGridModel:GetValue("Z0O_FS")
               Z0O->Z0O_PESO   := oGridModel:GetValue("Z0O_PESO")
               Z0O->Z0O_PESOPR := oGridModel:GetValue("Z0O_PESOPR")
               Z0O->Z0O_MCALPR := oGridModel:GetValue("Z0O_MCALPR")
               Z0O->Z0O_MCAPV := oGridModel:GetValue("Z0O_MCAPV")
               Z0O->Z0O_DTABAT := oGridModel:GetValue("Z0O_DTABAT")
               Z0O->Z0O_DIARIA := oGridModel:GetValue("Z0O_DIARIA")

            MsUnlock()
        endif
    next
    end transaction

    u_povoaBrw(.f.)
endif
if !Empty(aArea)
    RestArea(aArea)
endif
return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} vpcp07f3 
Consulta Padrao de Plano de Trato

@author jrscatolon@jrscatolon.com.br
@version 1.0
/*/
//-------------------------------------------------------------------
user function vpcp07f3()
local lRet := .F.
local aArea := GetArea()
local cQuery := ""
local cCampo := ReadVar()
local oModel := nil
local oGridModel := nil

if Type("uRetorno") == 'U' 
    public uRetorno
endif
uRetorno := ''

if "Z0O_CODPLA"$cCampo

    cQuery := " select Z0M.Z0M_CODIGO, Z0M_DESCRI, Max(R_E_C_N_O_) ZM0RECNO" +;
                " from " + RetSqlName("Z0M") + " Z0M" +;
               " where Z0M.Z0M_FILIAL = '" + FWxFilial("Z0M") + "'" +;
                 " and Z0M.D_E_L_E_T_ = ' '" +;
            " group by Z0M.Z0M_CODIGO, Z0M_DESCRI" +;
            " order by Z0M.Z0M_CODIGO"
    
    if u_F3Qry( cQuery, 'PLANUT', 'ZM0RECNO', @uRetorno,, { "Z0M_CODIGO", "Z0M_DESCRI" } )
        Z0M->(DbGoto( uRetorno ))
        lRet := .t.
    endif
    
elseif "Z0O_DIAIN"$cCampo 

    oModel := FWModelActive()
    oGridModel := oModel:GetModel("MdGridZ0O")

    cQuery := " select Z0M.Z0M_CODIGO, Z0M.Z0M_DIA, max(Z0M_DIETA) Z0M_DIETA, sum(Z0M.Z0M_QUANT) Z0M_QUANT, Z0M_DESCRI, Z0M_PESO, min(R_E_C_N_O_) ZM0RECNO " +;
                " from " + RetSqlName("Z0M") + " Z0M" +;
               " where Z0M.Z0M_FILIAL = '" + FWxFilial("Z0M") + "'" +;
                 " and Z0M.Z0M_CODIGO = '" + oGridModel:GetValue("Z0O_CODPLA") + "'" +;
                 " and Z0M.Z0M_VERSAO = (" +;
                     " select max(Z0M_VERSAO) Z0M_VERSAO" +;
                       " from " + RetSqlName("Z0M") + " Z0M1" +;
                      " where Z0M1.Z0M_FILIAL = Z0M.Z0M_FILIAL" +;
                        " and Z0M1.Z0M_CODIGO = Z0M.Z0M_CODIGO" +;
                        " and Z0M1.D_E_L_E_T_ = ' '" +;
                 " )" +;
                 " and Z0M.D_E_L_E_T_ = ' '" +;
            " group by Z0M.Z0M_CODIGO, Z0M.Z0M_DIA, Z0M_DESCRI, Z0M_PESO" +;
            " order by Z0M.Z0M_CODIGO, Z0M.Z0M_DIA"
    
    if u_F3Qry( cQuery, 'DIANUT', 'ZM0RECNO', @uRetorno,, { "Z0M_CODIGO", "Z0M_DIA" } )
        Z0M->(DbGoto( uRetorno ))
        lRet := .t.
    endif
    
endif

if aArea[1] <> "Z0M"
    RestArea( aArea )
endif
return lRet

user function  vpcp07ip()
local cVar := ReadVar()
local xRet := CriaVar(SubStr(cVar, 4), .f.) 
local oModel := nil

oModel := FWModelActive()
oGridModel := oModel:GetModel("MdGridZ0O")

if oGridModel:Length() > 0 
    xRet := oGridModel:GetValue(SubStr(cVar, 4), oGridModel:GetLine())
endif

return xRet 


user function  vpcp07tr()
local aArea := GetArea()
local cSql := ""
local cRet := Space(TamSX3("Z0M_DIA")[1])
local oModel := FWModelActive()
local oGridModel := oModel:GetModel("MdGridZ0O")

cSql := " select min(Z0M.Z0M_DIA) Z0M_DIA" +;
          " from " + RetSqlName("Z0M") + " Z0M" +;
         " where Z0M.Z0M_FILIAL = '" + FWxFilial("Z0M") + "'" +;
           " and Z0M.Z0M_CODIGO = '" + oGridModel:GetValue("Z0O_CODPLA") + "'" +;
           " and Z0M.Z0M_VERSAO = (" +;
               " select max(Z0M_VERSAO) Z0M_VERSAO" +;
                 " from " + RetSqlName("Z0M") + " Z0M1" +;
                " where Z0M1.Z0M_FILIAL = Z0M.Z0M_FILIAL" +;
                  " and Z0M1.Z0M_CODIGO = Z0M.Z0M_CODIGO" +;
                  " and Z0M1.D_E_L_E_T_ = ' '" +;
               " )" +;
           " and Z0M.D_E_L_E_T_ = ' '"

DbUseArea(.t., "TOPCONN", TCGenQry(,,cSql),"MINDIA", .f., .f.)

if !MINDIA->(Eof())
    cRet := MINDIA->Z0M_DIA
endif

MINDIA->(DbCloseArea())

if !Empty(aArea)
    RestArea(aArea)
endif
return cRet

user function vpcp07vl()
local lRet       := .t.
local i, nLen
local oModel     := FWModelActive()
local oGridModel := oModel:GetModel("MdGridZ0O")
local nLin       := oGridModel:GetLine()
//local dDataIni := oGridModel:GetValue("Z0O_DATAIN")
//local dDataFim := oGridModel:GetValue("Z0O_DATATR")
local cVar       := ReadVar()

if !oGridModel:IsDeleted(nLin)
    if "M->Z0O_CODPLA"$cVar
    // Empty(M->Z0O_CODPLA).or.ExistCpo("Z0M",M->Z0O_CODPLA)
        if !Empty(M->Z0O_CODPLA) .and. !Z0M->(DbSeek(FWxFilial("Z0M")+M->Z0O_CODPLA)) 
            Help(,, "C�digo do plano nutricional inv�lido",, "N�o foi encontrado o c�digo do plano nutricional.", 1, 0,,,,,, {"Por favor digite um c�digo de plano nutricional v�lido ou selecione." + CRLF + "<F3 Dispon�vel>."})
            lRet := .f.
        endif
    elseif "M->Z0O_DIAIN"$cVar
        if Empty(oGridModel:GetValue("Z0O_CODPLA")) .and. !Empty(M->Z0O_DIAIN)
            Help(,, "Plano nutricional inv�lido.",, "N�o � poss�vel validar o dia sem identificar o plano nutricional.", 1, 0,,,,,, {"Por favor digite um c�digo de plano nutricional v�lido ou selecione um antes de definir o dia de in�cio."})
            lRet := .f.
        elseif !Empty(oGridModel:GetValue("Z0O_CODPLA")) .and. !Z0M->(DbSeek(FWxFilial("Z0M")+oGridModel:GetValue("Z0O_CODPLA")+u_vpcp06ver(oGridModel:GetValue("Z0O_CODPLA"))+M->Z0O_DIAIN)) 
            Help(,, "Dia do plano nutricional inv�lido",, "O dia digitado n�o foi definido para o plano nutricional " + oGridModel:GetValue("Z0O_CODPLA") + ".", 1, 0,,,,,, {"Por favor digite um dia de inicio v�lido ou selecione." + CRLF + "<F3 Dispon�vel>."})
            lRet := .f.
        endif
    elseif "M->Z0O_DATAIN"$cVar
        if !Empty(oGridModel:GetValue("Z0O_DATATR")) .and. M->Z0O_DATAIN > oGridModel:GetValue("Z0O_DATATR")
            Help(,, "Data de in�cio do plano nutricional inv�lido",, "A data de in�cio do plano nutricional deve ser menor que a data de temino.", 1, 0,,,,,, {"Por favor, digite uma data v�lida."})
            lRet := .f.
        else
            nLen := oGridModel:Length()
            for i := 1 to nLen
                if i <> nLin .and. !oGridModel:IsDeleted(i) .and. M->Z0O_DATAIN <= oGridModel:GetValue("Z0O_DATATR", i) 
                    Help(,, "Data de in�cio do plano nutricional inv�lido",, "A data de in�cio do plano nutricional deve ser superior aos intervalos das das linhas anteriores.", 1, 0,,,,,, {"Por favor, digite uma data v�lida."})
                    lRet := .f.
                endif
            next
        endif 
    elseif "M->Z0O_DATATR"$cVar
        if Empty(M->Z0O_DATATR) .and. nLin != oGridModel:Length()
            Help(,, "Data de termino do plano nutricional inv�lido",, "A data de termino do plano nutricional pode estar em branco somente na �ltima linha do plano nutricional.", 1, 0,,,,,, {"Por favor, digite uma data v�lida."})
            lRet := .f.
        elseif !Empty(M->Z0O_DATATR) .and. M->Z0O_DATATR < oGridModel:GetValue("Z0O_DATAIN")
            Help(,, "Data de termino do plano nutricional inv�lido",, "A data de termino do plano nutricional deve ser superior que a data de inicio.", 1, 0,,,,,, {"Por favor, digite uma data v�lida."})
            lRet := .f.
        else
            nLen := oGridModel:Length()
            for i := 1 to nLen
                if i <> nLin .and. !oGridModel:IsDeleted(i)
                    if i < nLin .and. Empty(oGridModel:GetValue("Z0O_DATATR", i))
                        Help(,, "Data de termino do plano nutricional inv�lido",, "A data de termino do plano nutricional n�o est� preenchida na linha " + AllTrim(Str(i)) + ".", 1, 0,,,,,, {"Por favor, digite uma data v�lida para o intervalo anteriores antes de preencher as datas posteriores."})
                        lRet := .f.
                    elseif Empty(oGridModel:GetValue("Z0O_DATATR", i))
                        if M->Z0O_DATATR >= oGridModel:GetValue("Z0O_DATAIN", i)
                            Help(,, "Data de termino do plano nutricional inv�lido",, "A data de termino do plano nutricional deve ser superior as das linhas anteriores e inferior as linhas posteriores.", 1, 0,,,,,, {"Por favor, digite uma data v�lida."})
                            lRet := .f.
                        endif
                    else
                        if M->Z0O_DATATR >= oGridModel:GetValue("Z0O_DATAIN", i) .and. M->Z0O_DATATR <= oGridModel:GetValue("Z0O_DATATR", i)
                            Help(,, "Data de termino do plano nutricional inv�lido",, "A data de termino do plano nutricional deve ser superior as das linhas anteriores e inferior as linhas posteriores.", 1, 0,,,,,, {"Por favor, digite uma data v�lida."})
                            lRet := .f.
                        endif
                    endif 
                endif
            next
        endif 
    endif
endif

return lRet

user function F3Qry( cQuery, cCodCon, cCpoRecno, uRetorno, aSearch, cTela, cTabela )
local aArea := GetArea()
local aSeek := {}
local aIndex := {}
local cIdBrowse := ''
local cIdRodape := ''
local cTrab := GetNextAlias()
local i, nLen
local oBrowse, oDlg, oBtnOk, oBtnCan, oTela, oPnlBrw, oPnlRoda
local nButLeft := 0

local aCoord := {178, 0, 543, 800}

private lRetF3      := .F.

default aSearch := {}
default cTela := ""
default cTabela := ""

    //-------------------------------------------------------------------
    // Indica as chaves de Pesquisa
    //-------------------------------------------------------------------
    //[1] - Nome do Campo
    //[2] - Titulo do Campo
    //[3] - Tipo do Campo
    //[4] - Tamanho do Campo
    //[5] - Casas decimais
    //-------------------------------------------------------------------
    if !Empty (aSearch)
        nLen := Len(aSearch)
        for i:= 1 to nLen
            AAdd( aIndex, aSearch[i] )
            AAdd( aSeek, { AvSX3(aSearch[i],5), {{"",AvSX3(aSearch[i],2),AvSX3(aSearch[i],3),AvSX3(aSearch[i],4),AvSX3(aSearch[i],5),,}} } )

            if i == 1
                cQuery += " ORDER BY " + aSearch[i]
            endif
        next
    endif

    define msdialog oDlg from aCoord[1], aCoord[2] to aCoord[3], aCoord[4] title "Consulta Padr�o" pixel of oMainWnd 

    oTela     := FWFormContainer():New( oDlg )
    cIdBrowse := oTela:CreateHorizontalBox( 85 )
    cIdRodape := oTela:CreateHorizontalBox( 15 )
    oTela:Activate( oDlg, .F. )

    oPnlBrw   := oTela:GeTPanel( cIdBrowse )
    oPnlRoda  := oTela:GeTPanel( cIdRodape )

    oBrowse := CriaF3Brow(oDlg, oPnlBrw, cQuery, @cTrab, @uRetorno, aSeek, aIndex, cCodCon, cCpoRecno)

    @ oPnlRoda:nTop + 05, oPnlRoda:nLeft + 003 Button oBtnOk  Prompt "Confirma" Size 25, 11 Of oPnlRoda Pixel Action ( lRetF3 := .T., uRetorno := ( cTrab )->( FieldGet( FieldPos( cCpoRecno ) ) ) , oDlg:End() ) 
    @ oPnlRoda:nTop + 05, oPnlRoda:nLeft + 033 Button oBtnCan Prompt "Cancela" Size 25, 11 Of oPnlRoda Pixel Action ( lRetF3 := .F., oDlg:End() ) 

    nButLeft := 033

    //-------------------------------------------------------------------
    // Ativa��o do janela
    //-------------------------------------------------------------------
    Activate MsDialog oDlg Centered

    RestArea( aArea )

return lRetF3

static function CriaF3Brow(oDlg, oPnlBrw, cQuery, cTrab, uRetorno, aSeek, aIndex, cCodCon, cCpoRecno)
local oBrowse, oColumn
local i, nAt, nLen
local aCampos     := {}
local aStru       := {}
local aMatF3      := {}
local cTitCpo     :=  ''
local cPicCpo     :=  ''

    if Select(cTrab) > 0
        (cTrab)->(DbCloseArea())
        cTrab := GetNextAlias()
    elseif File(cTrab+GetDbExtension())
        cTrab := GetNextAlias()
    endif

    nAt := AScan( aMatF3, { | aX | aX[1] == PadR( cCodCon, 10 ) } )
    if !Empty( cCodCon )
        if nAt == 0
            aAdd( aMatF3, { PadR( cCodCon, 10 ) , cQuery, {} } )
        else
            cQuery := aMatF3[nAt][2]
        endif
    endif

    //-------------------------------------------------------------------
    // Define o Browse
    //-------------------------------------------------------------------
    define FWBrowse oBrowse showlimit data query alias cTrab query cQuery ;
           doubleclick { || lRetF3 := .T., uRetorno := (cTrab)->( FieldGet( FieldPos( cCpoRecno ) ) ), oDlg:End() } ;
           no locate filter seek order aSeek indexquery aIndex of oPnlBrw

    TcSetField( cTrab, cCpoRecno  , 'N', 12,0)

    //-------------------------------------------------------------------
    // Monta Estrutura de campos
    //-------------------------------------------------------------------
    if !Empty( cCodCon )
        if nAt == 0
            aStru := ( cTrab )->( dbStruct() )
            nLen := Len( aStru )
            for i := 1 to nLen

                //-------------------------------------------------------------------
                // Campos
                //-------------------------------------------------------------------
                // Estrutura do aFields
                //                [n][1] Campo
                //                [n][2] T�tulo
                //                [n][3] Tipo
                //                [n][4] Tamanho
                //                [n][5] Decimal
                //                [n][6] Picture
                //-------------------------------------------------------------------

                cTitCpo := aStru[i][1]
                cPicCpo := ''
                if AvSX3( aStru[i][1],, cTrab, .T. )
                    cTitCpo := RetTitle( aStru[i][1] )
                    cPicCpo := AvSX3( aStru[i][1], 6, cTrab )
                    if cPicCpo $ '@!'
                        cPicCpo := ''
                    endif
                endif

                if !PadR( cCpoRecno, 15 ) == PadR( aStru[i][1], 15 )
                    aAdd( aCampos, { aStru[i][1], cTitCpo,  aStru[i][2], aStru[i][3], aStru[i][4], cPicCpo } )
                endif
            next

            if !Empty( cCodCon )
                aMatF3[Len( aMatF3 )][3] := aCampos
            endif
        else
            aCampos := aClone( aMatF3[nAt][3] )
        endif
    endif

    //-------------------------------------------------------------------
    // Adiciona as colunas do Browse
    //-------------------------------------------------------------------
    for i := 1 to Len( aCampos )
        add column oColumn data &( '{ ||' + aCampos[i][1] + ' }' ) title aCampos[i][2] picture aCampos[i][6] of oBrowse
    next

    //-------------------------------------------------------------------
    // Adiciona as colunas do Filtro
    //-------------------------------------------------------------------
    oBrowse:SetFieldFilter( aCampos )
    oBrowse:SetUseFilter()

    //-------------------------------------------------------------------
    // Ativa��o do Browse
    //-------------------------------------------------------------------
    activate FWBrowse oBrowse

return oBrowse


user function StDiaTrato(cCodPlan)
local cDia := "01"

DbUseArea(.t., "TOPCONN", TCGenQry(,," select min(Z0M_DIA) Z0M_DIA" +;
                                       " from " + RetSqlName("Z0M") + " Z0M" +;
                                      " where Z0M.Z0M_FILIAL = '" + FWxFilial("Z0M") + "'" +;
                                        " and Z0M.Z0M_CODIGO = '" + cCodPlan + "'" +;
                                        " and Z0M.Z0M_VERSAO = ''";
                                  ), "TMPZ0M", .f., .f.)
return cDia


/*/{Protheus.doc} AtuSX1
Cria a(s) pergunta(s) usada(s) por essa rotina 
@author jrscatolon@jrscatolon.com.br
@since 22/02/2019
@version 1.0
@param cPerg, characters, Grupo da pergunta a ser criada
/*/
User function AtuSX107(cPerg)
local aArea    := GetArea()
local aAreaDic := SX1->( GetArea() )
local aEstrut  := {}
local aStruDic := SX1->( dbStruct() )
local aDados   := {}
local i       := 0
local j       := 0
local nTam1    := Len( SX1->X1_GRUPO )
local nTam2    := Len( SX1->X1_ORDEM )

cPerg := PadR(cPerg, Len(SX1->X1_GRUPO))

aEstrut := { "X1_GRUPO"  , "X1_ORDEM"  , "X1_PERGUNT", "X1_PERSPA" , "X1_PERENG" , "X1_VARIAVL", "X1_TIPO"   , ;
             "X1_TAMANHO", "X1_DECIMAL", "X1_PRESEL" , "X1_GSC"    , "X1_VALID"  , "X1_VAR01"  , "X1_DEF01"  , ;
             "X1_DEFSPA1", "X1_DEFENG1", "X1_CNT01"  , "X1_VAR02"  , "X1_DEF02"  , "X1_DEFSPA2", "X1_DEFENG2", ;
             "X1_CNT02"  , "X1_VAR03"  , "X1_DEF03"  , "X1_DEFSPA3", "X1_DEFENG3", "X1_CNT03"  , "X1_VAR04"  , ;
             "X1_DEF04"  , "X1_DEFSPA4", "X1_DEFENG4", "X1_CNT04"  , "X1_VAR05"  , "X1_DEF05"  , "X1_DEFSPA5", ;
             "X1_DEFENG5", "X1_CNT05"  , "X1_F3"     , "X1_PYME"   , "X1_GRPSXG" , "X1_HELP"   , "X1_PICTURE", ;
             "X1_IDFIL"  }
                         //123456789012345678901234567890 
AAdd( aDados, {cPerg,'01','Status do lote?               ','Estado del lote?              ','Lot status?                   ','mv_ch1','N', 1,0,1,'C','','mv_par01','Ativos','Activado','Active','','','Finalizados','Finalizado','Finished','','','Todos','Todos','All','','','','','','','','','','','','','','S','','','','', {"Informe quais lotes se deseja visualizar.", "Seleccione qu� lotes desea ver.", "Select which lots you want to view."}} )

DbSelectArea( "SX1" )
SX1->( DbSetOrder( 1 ) )

nLenLin := Len( aDados )
for i := 1 to nLenLin
    if !SX1->( DbSeek( PadR( aDados[i][1], nTam1 ) + PadR( aDados[i][2], nTam2 ) ) )
        RecLock( "SX1", .t. )
        nLenCol := Len( aEstrut )
        for j := 1 to nLenCol
            if aScan( aStruDic, { |aX| PadR( aX[1], 10 ) == PadR( aEstrut[j], 10 ) } ) > 0
                SX1->( FieldPut( FieldPos( aEstrut[j] ), aDados[i][j] ) )
            endif
        next
        MsUnLock()
        &('staticcall(vapcpa07, AtuSX1Hlp, "P." + AllTrim(SX1->X1_GRUPO) + AllTrim(SX1->X1_ORDEM) + ".", aDados[i][nLenCol+1], .t.)')
    endif
next

RestArea( aAreaDic )
RestArea( aArea )

return nil

Static Function comboRaca()
	Local cCombo := ''

	BeginSQL alias "QCMB"
	%noParser%
	select distinct Z09_RACA
	  from %table:Z09% Z09
	 where Z09_FILIAL=%xFilial:Z09%
	   and Z09_RACA <> ' '
	   and Z09.%notDel%
	 order by 1 desc
	EndSQL
	while !QCMB->(Eof())
		If !empty(QCMB->Z09_RACA)
			cCombo += If(empty(cCombo),"",";") + AllTrim(QCMB->Z09_RACA) + "=" + AllTrim(QCMB->Z09_RACA)
		EndIf
		QCMB->(dbSkip())
	EndDo
	QCMB->(dbCloseArea())

Return cCombo

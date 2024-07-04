#INCLUDE "TOTVS.ch"
#include "rwmake.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "DBTREE.CH"
#INCLUDE "MSOLE.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "GTPR286.CH"

/*/
 * {Protheus.doc} GTPR286()
 * Recebimento de Requisição 
 * type    Function
 * author  Eduardo Ferreira
 * since   11/02/2020
 * version 12.25
 * param   Não há
 * return  Não há
/*/
Function GTPR286()
Local cPastArq  := GTPGetRules("PASTARQDOT",,,"")
Local cNomeArq  := GTPGetRules("NOMEARQDOT",,,"")
Local cRootpath := Iif(ALLTRIM(RIGHT(GetSrvProfString("ROOTPATH",""), 1)) != '\', GetSrvProfString("ROOTPATH","") + '\' + cPastArq, GetSrvProfString("ROOTPATH","") + cPastArq)
Local cArquivo  := ''
Local cDirArq   := ''
Local nHandWord := 0
Local aEmpresa  := RetSM0()
Local aLote     := GetLote()

If Len(aEmpresa) <= 0
    MsgAlert(STR0004)
    Return 
ElseIf Len(aLote) <=0
    MsgAlert(STR0005)
    Return 
Endif 

If !ExistDir(cRootpath)
    FwMakeDir(cRootpath)
EndIf

If File(cRootpath + "\" + cNomeArq + ".dot")
    cArquivo := (cRootpath + "\" + cNomeArq + ".dot")
else
    MsgAlert(STR0001) //'Arquivo.Dot não encontrado no diretório!'
    Return 
EndIf

cDirArq := cGetFile("", STR0006,,,.F.,GETF_LOCALHARD+GETF_RETDIRECTORY)

//Cria um ponteiro e já chama o arquivo
nHandWord := OLE_CreateLink()

OLE_NewFile(nHandWord, cArquivo) //cArquivo deve conter o endereço que o dot está na máquina, por exemplo, C:\arquivos_dot\teste.dotx

//Setando o conteúdo das DocVariables Empresa
OLE_SetDocumentVar(nHandWord, "VarNota"   , aLote[1, 1])
OLE_SetDocumentVar(nHandWord, "VarNomeEmp", aEmpresa[1, 4])
OLE_SetDocumentVar(nHandWord, "VarEndEmp" , aEmpresa[1, 1])
OLE_SetDocumentVar(nHandWord, "VarMunEmp" , aEmpresa[1, 6])
OLE_SetDocumentVar(nHandWord, "VarEstEmp" , aEmpresa[1, 3])
OLE_SetDocumentVar(nHandWord, "VarCepEmp" , aEmpresa[1, 2])
OLE_SetDocumentVar(nHandWord, "VarTelEmp" , aEmpresa[1, 5])

//Setando o conteúdo das DocVariables Clientes
OLE_SetDocumentVar(nHandWord, "VarNomeCli", ALLTRIM(aLote[1, 02]))
OLE_SetDocumentVar(nHandWord, "VarCNPJCli", ALLTRIM(aLote[1, 08]))
OLE_SetDocumentVar(nHandWord, "VarInscEst", ALLTRIM(aLote[1, 12]))
OLE_SetDocumentVar(nHandWord, "VarEndCli" , ALLTRIM(aLote[1, 10]))
OLE_SetDocumentVar(nHandWord, "VarCidCli" , ALLTRIM(aLote[1, 11]))

OLE_SetDocumentVar(nHandWord, "VarCNPJEmp", ALLTRIM(aEmpresa[1, 07]))
OLE_SetDocumentVar(nHandWord, "VarValLote", aLote[1, 05])
OLE_SetDocumentVar(nHandWord, "VarValdesc", Extenso(aLote[1, 05]))

//Atualizando campos
OLE_UpdateFields(nHandWord)

OLE_PrintFile(nHandWord, "ALL",,, 1 )

Sleep(2000)

OLE_SaveAsFile(nHandWord, AllTrim(cDirArq + cNomeArq))

//Monstrando um alerta
MsgAlert(STR0002, STR0003)
 
//Fechando o arquivo e o link
OLE_CloseFile(nHandWord)
OLE_CloseLink(nHandWord)

Return 


/*/
 * {Protheus.doc} RetSM0()
 * Busca o Endereço da Filial da Agencia
 * type    Static Function
 * author  Eduardo Ferreira
 * since   11/02/2020
 * version 12.25
 * param   cCod
 * return  aRet
/*/
Static Function RetSM0()
Local aSM0     := SM0->(GetArea())
Local nPos     := 0
Local aRet     := {}
Local aEmpresa := FWLoadSM0()

nPos := aScan(aEmpresa,{|x| x[2] == cFilAnt}) 

dbselectarea("SM0")
SM0->(dbsetorder(1))

If SM0->(dbseek(aEmpresa[nPos,1]))
    aAdd(aRet,{SM0->M0_ENDCOB, SM0->M0_CEPCOB, SM0->M0_ESTENT, SM0->M0_NOME, SM0->M0_TEL, SM0->M0_CIDCOB, SM0->M0_CGC})       
endif
         
RestArea(aSM0)

Return aRet


/*/
 * {Protheus.doc} GetLote()
 * Montagem da query do Lote
 * type    Static Function
 * author  Eduardo Ferreira
 * since   11/02/2020
 * version 12.25
 * param   Não há
 * return  aAlias
/*/
Static Function GetLote()
Local aAlias := {}
Local cLote  := GQY->GQY_CODIGO
Local cAlias := GetNextAlias()

BeginSql Alias cAlias
    SELECT 
        GQY.GQY_CODIGO,
        GQY.GQY_CODCLI,
        GQY.GQY_CODLOJ,
        GQY.GQY_DTEMIS,
        (GQY.GQY_TOTAL - GQY.GQY_TOTDES) lIQUIDO,
        GQY.GQY_NOTA ,
        SA1.A1_CEP   , 
        SA1.A1_CGC   ,
        SA1.A1_INSCR ,
        SA1.A1_EST   ,
        SA1.A1_END   ,
        SA1.A1_MUN
    FROM 
        %Table:GQY% GQY 
        JOIN %Table:SA1% SA1 
		    ON  SA1.A1_FILIAL = %xFilial:SA1% 
		    AND SA1.A1_COD = GQY.GQY_CODCLI
            AND SA1.%NotDel%
    WHERE 
        GQY.GQY_FILIAL = %xFilial:GQY%  
        AND GQY.GQY_CODIGO = %Exp:cLote%
        AND GQY.%NotDel%
EndSql

While !(cAlias)->(Eof())
    aAdd(aAlias,{(cAlias)->GQY_CODIGO,;
                 (cAlias)->GQY_CODCLI,;
                 (cAlias)->GQY_CODLOJ,;
                 (cAlias)->GQY_DTEMIS,;
                 (cAlias)->lIQUIDO   ,;
                 (cAlias)->GQY_NOTA  ,;
                 (cAlias)->A1_CEP    ,;
                 (cAlias)->A1_CGC    ,;
                 (cAlias)->A1_EST    ,;
                 (cAlias)->A1_END    ,;
                 (cAlias)->A1_MUN    ,;
                 (cAlias)->A1_INSCR  })

    (cAlias)->(dbSkip())
End

(cAlias)->(DbCloseArea())   

Return aAlias

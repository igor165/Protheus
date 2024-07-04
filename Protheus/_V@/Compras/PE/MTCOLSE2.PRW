#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#include "RWMAKE.CH"
#include "colors.ch"
#INCLUDE "TBICONN.CH"

User Function MTCOLSE2()
    Local aColsE2   := PARAMIXB[1] //aCols de duplicatas
    Local nOpc      := PARAMIXB[2] //0-Tela de visualização / 1-Inclusão ou Classificação
    Local _cQry     := ''
    Local nAt       := Len(aCols)
    Local nI,nX
    Local aDados    := {}
    Local aSE2      := {}
    Local cPed      := ''
    Local lPula

    if nOpc == 1
        _cQry := " SELECT ZBC_CODIGO,ZBC_VERSAO,ZBC_PEDIDO FROM "+RetSqlName("ZBC")+" " + CRLF
        _cQry += " WHERE ZBC_PEDIDO = '"+aCols[nAt][16]+"' " + CRLF
        _cQry += " AND D_E_L_E_T_ = ''  " + CRLF

        MpSysOpenQry(_cQry,"TMP")
        
        MemoWrite( "C:\totvs_relatorios\MTCOLSE2_ZBC.sql",_cQry )

        if !TMP->(EOF())
            _cQry := " select * from "+RetSqlName("ZBD")+"  " + CRLF 
            _cQry += " WHERE ZBD_CODZCC = '"+TMP->ZBC_CODIGO+"'  " + CRLF 
            _cQry += " AND ZBD_ZCCVER = '"+TMP->ZBC_VERSAO+"'  " + CRLF
            _cQry += " AND ZBD_CODPED != ''  " + CRLF
            _cQry += " AND D_E_L_E_T_ = ''  " + CRLF
            _cQry += " order by ZBD_CODPED,ZBD_ITEM " + CRLF
            
            MemoWrite( "C:\totvs_relatorios\MTCOLSE2_ZBD_.sql",_cQry )

            MpSysOpenQry(_cQry,"TEMP")

            WHILE !TEMP->(Eof())
                if cPed != TEMP->ZBD_CODPED .and. Len(aSE2) > 0 
                    aAdd(aDados,{cPed,aSE2})
                    aSE2 := {}
                endif
                
                aAdd(aSE2,{TEMP->ZBD_ITEM,sTod(TEMP->ZBD_DATA)})

                cPed := TEMP->ZBD_CODPED
                TEMP->(DBSkip())
            EndDo

            if Len(aSE2) > 0
                aAdd(aDados,{cPed,aSE2})
                aSE2 := {}
            endif
            
            if Len(aDados) > 1
                For nI := 2 to Len(aDados)
                    For nX := 1 to Len(aDados[nI][2])
                        if aDados[1][2][nX][2] != aDados[nI][2][nX][2]
                            MSGALERT( "Validar vencimentos do contrato antes de finalizar a nota. Validar com o comprador responsável!", "Atenção!" )
                            lPula := .T.
                            exit
                        endif
                    Next nX
                    if lPula
                        EXIT
                    endif
                Next nI
            endif 

            if !lPula
                For nI := 1 to Len(aDados)
                    if aDados[nI][1] == TMP->ZBC_PEDIDO
                        For nX := 1 to Len(aDados[nI][2])
                            aColsE2[nX][2] := aDados[nI][2][nX][2]
                        Next nX
                    endif 
                Next nI 
            endif 

            TEMP->(DbCloseArea())
        endif 
        TMP->(DbCloseArea())
    endif
Return aColsE2
/* 
User FUnction MT103SEL()
    Local nRecno := PARAMIXB[1]
    Local aArea  := GetArea()
    Local nRet   := 0
    dbSelectArea('SC7')
    dbGoto(nRecno)//Validacoes do usuarioRestArea(aArea)Return(nRet) 
Return
User FUnction MT103APC()
Local lRet := .T.

Return lRet

User FUnction MT103QPC()
    Local cQry:=ParamIxb[1]
    Local nOpc:=ParamIxb[2]
    Local cQryRet:= ""
    
    If nOpc==1
        cQryRet:= cQry// Montar a Query ao pressionar F5Else    cQryRet:= // Montar a Query ao pressionar F6
    EndIf
Return cQryRet

User FUnction M103PCIT()
Return 
 */

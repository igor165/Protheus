#include "Protheus.ch"

/*/{Protheus.doc} MATAMAP
    Nova rotina para geração do Mapa de Controle de Produtos Químicos conforme Portaria nº 240 de 12 de Março de 2019.
    A nova legislação entra em vigor em 01/09/2019 conforme Portaria nº 577 de 05 de Junho de 2019.
    @type  Function
    @author SQUAD Entradas
    @since 01/08/2019
    @version P12.1.25
    @see (http://www.in.gov.br/materia/-/asset_publisher/Kujrw0TZC2Mb/content/id/66952742/do1-2019-03-14-portaria-n-240-de-12-de-marco-de-2019-66952457)
/*/
Function MATAMAP(dDataDe, dDataAte, cArqDest, cDir, nProcFil)

    Local oMapasPF
    Local cGrupoDe := ""
    Local cGrupoAte := ""
    Local cProdDe := ""
    Local cProdAte := ""
    Local cFilBkp := ""
    Local cDeclMapas := ""
    Local nFil := 0
    Local lRet := .T.
    Local lFileOk := .F.
    Local lMAPPFTP := ExistBlock("MAPPFTP")
    Local aFilsCalc := MatFilCalc(nProcFil == 1)

    If Empty(aFilsCalc)
        lRet := .F.
    EndIf
    
    If lRet .And. !Pergunte("MAPASV2", .T.)
        lRet := .F.
    EndIf
    
    cGrupoDe := mv_par01
    cGrupoAte := mv_par02
    cProdDe := mv_par03
    cProdAte := mv_par04
    cDeclMapas := mv_par05
    
    If lRet
    
        cFilBkp := cFilAnt
    
        For nFil := 1 to Len(aFilsCalc)
    
            If aFilsCalc[nFil][1]
    
                cFilAnt  := aFilsCalc[nFil][2]
    
                oMapasPF := MAPASPF():New(dDataDe, dDataAte, cGrupoDe, cGrupoAte, cProdDe, cProdAte, nProcFil, aFilsCalc[nFil][4], cDeclMapas)
    
                If !oMapasPF:lConfigOk
                    Exit
                EndIf
    
                If lMAPPFTP
                    ExecBlock("MAPPFTP",.F.,.F.,{oMapasPF:aTrab})
                EndIf

                lFileOk := oMapasPF:GeraTXT(cArqDest, cDir)
    
                oMapasPF:Destructor()
    
                FreeObj(oMapasPF)
    
                If !lFileOk
                    Exit
                EndIf
    
            EndIf
    
        Next
    
        cFilAnt := cFilBkp
   
    EndIf

Return (lRet)

#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

#Define PAD_LEFT    0
#Define PAD_RIGHT   1
#Define PAD_CENTER  2

//+-----------------------------------------------------------------------+
//| Funcao | UL_OPMENU   | Autor | Vagner Azanha      | Data | 08/12/2020 |
//+-----------------------------------------------------------------------+
//| Descr. | Programa Principal que chama as Impressao de OP              |
//+-----------------------------------------------------------------------+
//| Uso    | PCP		                                                  |
//+-----------------------------------------------------------------------+
User Function UL_OPMENU()
    Local aParamBox	:= {}
    Local aRet 	:= {}
    Local nF 		:= 0

    Private _cOpIni
    Private _cOpFim
    Private _dDtIni
    Private _dDtFim

    Private _nNumGrade
    Private _nGradFalt
    Private _nTotLinhas := 2900
    Private _nTotLin    := 3100
    Private _nNumOP
    Private _lImpCab 
    Private _nLinFinal := 2700



    AADD(aParamBox,{1,"Da OP", Space(TamSx3("C2_NUM")[1]) + Space(TamSx3("C2_ITEM")[1]) + Space(TamSx3("C2_SEQUEN")[1] ),"","","SC2","",0,.F.}) 	
    AADD(aParamBox,{1,"Ate OP", Space(TamSx3("C2_NUM")[1]) + Space(TamSx3("C2_ITEM")[1]) + Space(TamSx3("C2_SEQUEN")[1] ),"","","SC2","",0,.T.}) 	
    AADD(aParamBox,{1,"Emissao de", ctod("  /  /    ") ,"","","","",0,.F.}) 																					
    AADD(aParamBox,{1,"Emissao Ate", ctod("  /  /   ") ,"","","","",0,.T.}) 

    if ParamBox(aParamBox,"Relatório de Ordens de Produção, V3.5",aRet)
       _cOPIni := aRet[1]
       _cOpFim := aRet[2]
       _dDtIni := aRet[3]
       _dDtFim := aRet[4] 
       MsgRun("Aguarde...","Processando",{|| U_UL_ORDPROD(mv_par01,mv_par02,mv_par03,mv_par04)})
    endif

return nil

